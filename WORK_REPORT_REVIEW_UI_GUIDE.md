# Work Report Review Dialog - UI/UX Guide

## Dialog Structure Overview

```
╔══════════════════════════════════════════════════════════════════════════════╗
║                    🔵 Review Work Report Dialog                              ║
║                    Reviews and approves daily work reports                   ║
║ [X]                                                                          ║
╠══════════════════════════════════════════════════════════════════════════════╣
║                                                                              ║
║ 👤 EMPLOYEE INFORMATION CARD                                                ║
║ ┌──────────────────────────────────────────────────────────────────────┐    ║
║ │                                                                      │    ║
║ │ John Michael                                   [SUBMITTED]           │    ║
║ │ johnmichael5@gmail.com                                              │    ║
║ │                                                                      │    ║
║ │ Date: 15 Nov 2024  │  Hours: 7.0 hrs  │  Mood: 😊  │  Items: 2    │    ║
║ │                                                                      │    ║
║ └──────────────────────────────────────────────────────────────────────┘    ║
║                                                                              ║
║ 📋 ACTIVITIES SUMMARY                                                       ║
║ ┌──────────────────────────────────────────────────────────────────────┐    ║
║ │                                                                      │    ║
║ │ ┌────────────────────────────────────────────────────────────────┐  │    ║
║ │ │ Dashboard UI Implementation          [Development]            │  │    ║
║ │ │ Designed and implemented the main dashboard layout            │  │    ║
║ │ │ 5.0 hours                                      ✓ Completed    │  │    ║
║ │ └────────────────────────────────────────────────────────────────┘  │    ║
║ │                                                                      │    ║
║ │ ┌────────────────────────────────────────────────────────────────┐  │    ║
║ │ │ Code Review                          [Code Review]            │  │    ║
║ │ │ Reviewed pull requests from the team                          │  │    ║
║ │ │ 2.0 hours                                      ✓ Completed    │  │    ║
║ │ └────────────────────────────────────────────────────────────────┘  │    ║
║ │                                                                      │    ║
║ └──────────────────────────────────────────────────────────────────────┘    ║
║                                                                              ║
║ 📄 REPORT DETAILS                                                           ║
║                                                                              ║
║ Achievements ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━    ║
║ ┌─────────────────────────────────────────────────────────────────────────┐  ║
║ │ Completed dashboard implementation ahead of schedule                   │  ║
║ └─────────────────────────────────────────────────────────────────────────┘  ║
║                                                                              ║
║ Challenges ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━  ║
║ ┌─────────────────────────────────────────────────────────────────────────┐  ║
║ │ Had some difficulty with responsive design on mobile screens           │  ║
║ └─────────────────────────────────────────────────────────────────────────┘  ║
║                                                                              ║
║ Plan for Next Day ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━  ║
║ ┌─────────────────────────────────────────────────────────────────────────┐  ║
║ │ Fix responsive issues and start on profile page                        │  ║
║ └─────────────────────────────────────────────────────────────────────────┘  ║
║                                                                              ║
║ ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ ║
║                                                                              ║
║ YOUR REVIEW                                                                 ║
║                                                                              ║
║ Review Actions (Select One)                                                 ║
║ ┌────────────────────────────────────────────────────────────────────┐      ║
║ │ ✓ Approve Report                                            [●]    │      ║
║ └────────────────────────────────────────────────────────────────────┘      ║
║ ┌────────────────────────────────────────────────────────────────────┐      ║
║ │ 🔄 Request Rework                                           [ ]    │      ║
║ └────────────────────────────────────────────────────────────────────┘      ║
║ ┌────────────────────────────────────────────────────────────────────┐      ║
║ │ ❌ Reject Report                                             [ ]    │      ║
║ └────────────────────────────────────────────────────────────────────┘      ║
║                                                                              ║
║ Feedback * ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ ║
║ ┌─────────────────────────────────────────────────────────────────────────┐  ║
║ │ Great work on the dashboard! The layout is clean and well-organized.  │  ║
║ │ Just need to address the mobile responsiveness issues.                 │  ║
║ │                                                                       │  ║
║ └─────────────────────────────────────────────────────────────────────────┘  ║
║                                                                              ║
║ ℹ️ This report will be marked as approved                                   ║
║                                                                              ║
╠══════════════════════════════════════════════════════════════════════════════╣
║                                    [Cancel]  [Submit Review]                 ║
╚══════════════════════════════════════════════════════════════════════════════╝
```

---

## Review Action Selection States

### Default State (No Selection)
```
┌────────────────────────────────────────┐
│ ✓ Approve Report              [ ]      │
└────────────────────────────────────────┘
```

### Selected State
```
┌════════════════════════════════════════╗
║ ✓ Approve Report              [●]      ║
╚════════════════════════════════════════╝
```

### Reject Action Selected (Red)
```
┌════════════════════════════════════════╗
║ ❌ Reject Report              [●]      ║
╚════════════════════════════════════════╝
```

### Rework Action Selected (Orange, with Instructions)
```
┌════════════════════════════════════════╗
║ 🔄 Request Rework            [●]      ║
╚════════════════════════════════════════╝
[Additional field appears below]
```

---

## Conditional Fields

### When Approve is Selected
```
Feedback * ━━━━━━━━━━━━━━━━━━━━━━━━━━━━
┌─────────────────────────────────────┐
│ [Feedback text area - Required]      │
└─────────────────────────────────────┘
```

### When Rework Requested is Selected
```
Feedback * ━━━━━━━━━━━━━━━━━━━━━━━━━━━━
┌─────────────────────────────────────┐
│ [Feedback text area - Required]      │
└─────────────────────────────────────┘

Rework Instructions * ━━━━━━━━━━━━━━━━
┌─────────────────────────────────────┐
│ [Detailed instructions - Required]   │
│ Specify what needs to be reworked    │
└─────────────────────────────────────┘
```

### When Reject is Selected
```
Feedback * ━━━━━━━━━━━━━━━━━━━━━━━━━━━━
┌─────────────────────────────────────┐
│ [Feedback text area - Required]      │
│ Explain why report is rejected       │
└─────────────────────────────────────┘
```

---

## Activity Card Layout

### Standard Activity Card
```
┌─────────────────────────────────────────────────────────────┐
│                                                             │
│ Task Title                           [Category Badge]       │
│ Description of the work activity...                         │
│                                                             │
│ 5.0 hours                            ✓ Completed           │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### Activity with Different Categories

**Development (Blue)**
```
┌─────────────────────────────────────────────────────────────┐
│ Task Title                           [Development]          │
└─────────────────────────────────────────────────────────────┘
```

**Testing (Purple)**
```
┌─────────────────────────────────────────────────────────────┐
│ Task Title                           [Testing]              │
└─────────────────────────────────────────────────────────────┘
```

**Bug Fix (Red)**
```
┌─────────────────────────────────────────────────────────────┐
│ Task Title                           [Bug Fix]              │
└─────────────────────────────────────────────────────────────┘
```

---

## Information Card Layout

### Employee Info Summary
```
┌──────────────────────────────────────────────┐
│ Name              Status Badge               │
│ Email Address                                │
│ ──────────────────────────────────────────── │
│ Date     │   Hours   │  Mood  │  Activities │
│ 15 Nov   │  7.0 hrs  │  😊   │  2 items    │
└──────────────────────────────────────────────┘
```

---

## Status Badge Colors

| Status | Color | Use Case |
|--------|-------|----------|
| Approved | 🟢 Green | Report accepted and finalized |
| Submitted | 🔵 Blue | Awaiting manager review |
| Rework Required | 🟠 Orange | Employee needs to make changes |
| Rejected | 🔴 Red | Report not acceptable, must resubmit |
| Draft | ⚫ Gray | Not yet submitted by employee |

---

## Color Scheme

### Button/Action Colors
- **Approve**: Green (#16A34A)
- **Rework**: Orange (#F39C12)
- **Reject**: Red (#EC2623)

### Text Colors
- **Primary**: Black/Dark Gray
- **Secondary**: #64748B (Gray)
- **Success**: Green
- **Error**: Red
- **Warning**: Orange

### Background Colors
- **Dialog**: White
- **Header**: Light Blue (#F0F9FF)
- **Info Boxes**: Light Gray (#F3F4F6)
- **Selected Actions**: Tinted with action color

---

## Loading States

### Submission in Progress
```
┌──────────────────────────┐
│ ⏳ Submitting...          │
│ [disabled]               │
└──────────────────────────┘
```

### Success Notification
```
┌─────────────────────────────────────────────┐
│ ✓ Work report approved successfully         │
│ [Green background]                          │
└─────────────────────────────────────────────┘
```

### Error Notification
```
┌─────────────────────────────────────────────┐
│ ✗ Please provide feedback for this review   │
│ [Red background]                            │
└─────────────────────────────────────────────┘
```

---

## Responsive Breakpoints

### Desktop (> 1000px)
- Full width dialog with max-width: 1000px
- All content visible
- Multi-column layouts available

### Tablet (600px - 1000px)
- Dialog takes 90% of screen width
- Single column layouts
- All features preserved

### Mobile (< 600px)
- Full screen dialog (minus margins)
- Scrollable content
- Touch-friendly buttons
- Vertical layout for all sections

---

## Interaction Flow Diagram

```
User Opens Dialog
        ↓
Displays Employee Info & Report
        ↓
User Selects Action
(Approve/Rework/Reject)
        ├─→ [Rework] → Conditional field appears
        ├─→ [Approve] → Feedback only
        └─→ [Reject] → Feedback only
        ↓
User Enters Feedback
(+ Instructions if rework)
        ↓
Button Enabled: "Submit Review"
        ↓
User Clicks Submit
        ↓
Loading State (800ms)
        ↓
Success Snackbar Appears
        ↓
Dialog Closes
        ↓
List Updates with New Status
```

---

## Keyboard Interactions

| Key | Action |
|-----|--------|
| Tab | Navigate between fields |
| Shift+Tab | Navigate backwards |
| Enter | Submit (if focused on button) |
| Escape | Close dialog |
| Space | Select action option |

---

## Accessibility Features

- ✅ Semantic HTML structure
- ✅ Clear form labels
- ✅ Color not sole indicator (icons + text)
- ✅ Required field indicators (*)
- ✅ Error messages with context
- ✅ Focus indicators on buttons
- ✅ Readable contrast ratios
- ✅ Logical tab order

---

## Error Messages & Help Text

### Validation Errors
```
❌ "Please provide feedback for this review"
❌ "Please provide rework instructions"
```

### Info Messages
```
ℹ️ "Select a review action above"
ℹ️ "This report will be marked as approved"
ℹ️ "Employee will be notified to rework the report"
ℹ️ "This report will be rejected"
```

---

## Tips for Users

**For Managers:**
1. Always read through all activities before deciding
2. Provide constructive feedback, not just approval
3. Be specific with rework instructions
4. Consider the employee's mood when writing feedback
5. Check hours worked aligns with normal schedule

**For Employees:**
1. Submit complete and honest reports daily
2. If rework requested, carefully read instructions
3. Update report with specific improvements
4. Resubmit promptly for approval
5. If rejected, start fresh with new report

---

**Design Version:** 1.0
**Last Updated:** November 2024
**Status:** Production Ready ✅
