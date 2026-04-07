// Global state
let livenessVideo = null;
let stream = null;
let livenessInterval = null;
let modelsLoaded = false;
let challengeComplete = false;

// ── Head turn challenge state ────────────────────────────────────────────────
//
// Flow (user must turn BOTH ways for liveness):
//   STATE_WAIT_CENTER  → user must align face roughly centered (yaw ~ 0)
//   STATE_WAIT_TURN_1  → user must turn head in first direction
//   STATE_WAIT_TURN_2  → user must turn head in second (opposite) direction
//   STATE_WAIT_RETURN  → user must return face to center
//   STATE_CAPTURE      → snapshot taken
//
// Yaw is calculated from horizontal nose position relative to face bounding box.
//   yawRatio = (noseX - boxCenterX) / (boxWidth / 2)
//   Range roughly -1.0 (full left) to +1.0 (full right). Mirrored video is handled.

const STATE_WAIT_CENTER = 'wait_center';
const STATE_WAIT_TURN_1 = 'wait_turn_1';
const STATE_WAIT_TURN_2 = 'wait_turn_2';
const STATE_WAIT_RETURN = 'wait_return';
const STATE_CAPTURE = 'capture';

const CENTER_THRESHOLD = 0.15;  // |yaw| must be below this to count as centered
const TURN_THRESHOLD = 0.30;    // |yaw| must exceed this in correct direction
const STABLE_FRAMES_REQUIRED = 2; // how many consecutive frames in target state
const MIN_MESSAGE_DISPLAY_MS = 1200; // minimum time a "new instruction" stays before changing
const TRANSITION_PAUSE_MS = 800; // pause after state transition so user reads new prompt

let state = STATE_WAIT_CENTER;
let firstDirection = 'left';   // randomized on start
let secondDirection = 'right';
let stableFrames = 0;
let lastMessage = '';
let lastImportantMessageAt = 0;
let stateEnteredAt = 0;

// Messages that count as "instructions" and should be held visible longer
const IMPORTANT_KEYWORDS = ['Look straight', 'turn your head', 'return to center', 'Verified'];

async function loadFaceModels() {
    if (modelsLoaded) return true;
    try {
        const MODEL_URL = 'https://cdn.jsdelivr.net/npm/@vladmandic/face-api/model/';
        await faceapi.nets.tinyFaceDetector.loadFromUri(MODEL_URL);
        await faceapi.nets.faceLandmark68Net.loadFromUri(MODEL_URL);
        modelsLoaded = true;
        return true;
    } catch (e) {
        console.error("FaceAPI Load Error", e);
        if (window.onBiometricError) {
            window.onBiometricError("Failed to load ML models. Check network.");
        }
        return false;
    }
}

// Compute yaw ratio from face landmarks + detection box
function getYawRatio(detection) {
    const box = detection.detection.box;
    const landmarks = detection.landmarks;

    // Nose tip is point 30 in 68-landmark model
    const nose = landmarks.positions[30];

    const boxCenterX = box.x + box.width / 2;
    const halfWidth = box.width / 2;

    if (halfWidth === 0) return 0;

    // Raw ratio: positive = nose right of center, negative = nose left of center
    let ratio = (nose.x - boxCenterX) / halfWidth;

    // The video is mirrored via CSS (scaleX(-1)), so a user turning RIGHT
    // appears to move LEFT in the camera feed. Flip the sign so the values
    // match user-perspective directions.
    ratio = -ratio;

    return ratio;
}

function pickRandomDirection() {
    return Math.random() < 0.5 ? 'left' : 'right';
}

function isImportant(msg) {
    return IMPORTANT_KEYWORDS.some(k => msg.includes(k));
}

function progress(msg) {
    // Don't re-send the same message (eliminates flicker)
    if (msg === lastMessage) return;

    const now = Date.now();

    // If the previous message was an "important" instruction, hold it visible
    // for at least MIN_MESSAGE_DISPLAY_MS unless the new message is ALSO important
    // (state transitions always go through).
    if (isImportant(lastMessage) && !isImportant(msg)) {
        if (now - lastImportantMessageAt < MIN_MESSAGE_DISPLAY_MS) {
            return; // skip this less-important update
        }
    }

    lastMessage = msg;
    if (isImportant(msg)) {
        lastImportantMessageAt = now;
    }

    if (window.onBiometricProgress) {
        window.onBiometricProgress(msg);
    }
}

function transitionTo(newState) {
    state = newState;
    stableFrames = 0;
    stateEnteredAt = Date.now();
}

function captureFrameAsBase64() {
    const canvas = document.createElement('canvas');
    canvas.width = livenessVideo.videoWidth;
    canvas.height = livenessVideo.videoHeight;
    const ctx = canvas.getContext('2d');
    ctx.drawImage(livenessVideo, 0, 0, canvas.width, canvas.height);
    return canvas.toDataURL('image/jpeg', 0.85).split(',')[1];
}

window.startLivenessCheck = async function(videoElementId) {
    console.log("startLivenessCheck called. ID = " + videoElementId);

    // Reset state — randomize whether they turn left-then-right or right-then-left
    challengeComplete = false;
    state = STATE_WAIT_CENTER;
    if (Math.random() < 0.5) {
        firstDirection = 'left';
        secondDirection = 'right';
    } else {
        firstDirection = 'right';
        secondDirection = 'left';
    }
    stableFrames = 0;
    lastMessage = '';
    lastImportantMessageAt = 0;
    stateEnteredAt = Date.now();

    const loaded = await loadFaceModels();
    if (!loaded) return;

    livenessVideo = document.getElementById(videoElementId);
    if (!livenessVideo) {
        console.error("Video element not found!");
        return;
    }

    try {
        stream = await navigator.mediaDevices.getUserMedia({
            video: { facingMode: 'user', width: 640, height: 480 }
        });
        livenessVideo.srcObject = stream;
        livenessVideo.play();
    } catch (err) {
        console.error("Camera access denied", err);
        if (window.onBiometricError) window.onBiometricError("Camera access denied");
        return;
    }

    livenessVideo.addEventListener('play', () => {
        livenessInterval = setInterval(async () => {
            if (challengeComplete || !livenessVideo || livenessVideo.paused || livenessVideo.ended) return;

            const detection = await faceapi.detectSingleFace(
                livenessVideo,
                new faceapi.TinyFaceDetectorOptions({ inputSize: 224, scoreThreshold: 0.5 })
            ).withFaceLandmarks();

            if (!detection) {
                stableFrames = 0;
                progress("Align your face in the camera");
                return;
            }

            // Pause detection briefly after state transition so user can read the new prompt
            if (Date.now() - stateEnteredAt < TRANSITION_PAUSE_MS) {
                return;
            }

            const yaw = getYawRatio(detection);
            console.log(`State: ${state} | First: ${firstDirection} | Second: ${secondDirection} | Yaw: ${yaw.toFixed(3)} | Stable: ${stableFrames}`);

            switch (state) {
                case STATE_WAIT_CENTER: {
                    if (Math.abs(yaw) < CENTER_THRESHOLD) {
                        stableFrames += 1;
                        if (stableFrames >= STABLE_FRAMES_REQUIRED) {
                            transitionTo(STATE_WAIT_TURN_1);
                            progress(`Now turn your head to the ${firstDirection.toUpperCase()}`);
                        }
                    } else {
                        stableFrames = 0;
                        progress("Look straight at the camera");
                    }
                    break;
                }

                case STATE_WAIT_TURN_1: {
                    const turnedCorrectly =
                        (firstDirection === 'left' && yaw < -TURN_THRESHOLD) ||
                        (firstDirection === 'right' && yaw > TURN_THRESHOLD);

                    if (turnedCorrectly) {
                        stableFrames += 1;
                        if (stableFrames >= STABLE_FRAMES_REQUIRED) {
                            transitionTo(STATE_WAIT_TURN_2);
                            progress(`Now turn your head to the ${secondDirection.toUpperCase()}`);
                        }
                    } else {
                        stableFrames = 0;
                        progress(`Now turn your head to the ${firstDirection.toUpperCase()}`);
                    }
                    break;
                }

                case STATE_WAIT_TURN_2: {
                    const turnedCorrectly =
                        (secondDirection === 'left' && yaw < -TURN_THRESHOLD) ||
                        (secondDirection === 'right' && yaw > TURN_THRESHOLD);

                    if (turnedCorrectly) {
                        stableFrames += 1;
                        if (stableFrames >= STABLE_FRAMES_REQUIRED) {
                            transitionTo(STATE_WAIT_RETURN);
                            progress("Great! Now return to center");
                        }
                    } else {
                        stableFrames = 0;
                        progress(`Now turn your head to the ${secondDirection.toUpperCase()}`);
                    }
                    break;
                }

                case STATE_WAIT_RETURN: {
                    if (Math.abs(yaw) < CENTER_THRESHOLD) {
                        stableFrames += 1;
                        if (stableFrames >= STABLE_FRAMES_REQUIRED) {
                            state = STATE_CAPTURE;
                            challengeComplete = true;
                            progress("Verified! Capturing...");

                            const base64Data = captureFrameAsBase64();
                            window.stopLivenessCheck();

                            if (window.onBiometricSuccess) {
                                window.onBiometricSuccess(base64Data);
                            }
                        }
                    } else {
                        stableFrames = 0;
                        progress("Now return to center");
                    }
                    break;
                }
            }
        }, 150);
    });
};

window.stopLivenessCheck = function() {
    if (livenessInterval) {
        clearInterval(livenessInterval);
        livenessInterval = null;
    }
    if (stream) {
        stream.getTracks().forEach(track => track.stop());
        stream = null;
    }
    if (livenessVideo) {
        livenessVideo.srcObject = null;
        livenessVideo = null;
    }
    state = STATE_WAIT_CENTER;
    stableFrames = 0;
    challengeComplete = false;
    lastMessage = '';
    lastImportantMessageAt = 0;
};
