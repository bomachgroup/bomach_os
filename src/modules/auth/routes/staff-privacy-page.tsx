import type { ReactNode } from 'react'
import {
  ArrowLeft,
  BellRing,
  Camera,
  Fingerprint,
  LockKeyhole,
  MapPin,
  ShieldCheck,
  UserRound,
} from 'lucide-react'

const sections = [
  { id: 'information', label: 'Information we use' },
  { id: 'face-verification', label: 'Face verification' },
  { id: 'location', label: 'Location' },
  { id: 'files', label: 'Reports and files' },
  { id: 'sharing', label: 'How information is shared' },
  { id: 'retention', label: 'Retention and your choices' },
  { id: 'security', label: 'Security and contact' },
]

function Section({
  id,
  title,
  icon,
  children,
}: {
  id: string
  title: string
  icon: ReactNode
  children: ReactNode
}) {
  return (
    <section id={id} className="border-border-subtle scroll-mt-8 border-t py-7 sm:py-9">
      <div className="flex items-start gap-4">
        <span className="bg-primary-subtle text-primary mt-0.5 flex size-10 shrink-0 items-center justify-center rounded-xl">
          {icon}
        </span>
        <div className="min-w-0">
          <h2 className="text-h3 text-text-primary font-semibold tracking-tight">{title}</h2>
          <div className="text-body-sm text-text-secondary mt-3 space-y-3 leading-7">
            {children}
          </div>
        </div>
      </div>
    </section>
  )
}

export function StaffPrivacyPage() {
  return (
    <main className="bg-background text-text-primary min-h-svh px-4 py-5 sm:px-6 sm:py-8">
      <div className="mx-auto w-full max-w-5xl">
        <header className="border-border-subtle bg-surface shadow-elevation-sm flex flex-wrap items-center justify-between gap-4 rounded-2xl border px-4 py-3 sm:px-6">
          <a href="/login" className="flex min-w-0 items-center gap-3">
            <img src="/bomach-logo.png" alt="Bomach Group" className="h-11 w-auto object-contain" />
            <span className="border-border-subtle hidden h-8 border-l sm:block" />
            <span className="text-label text-text-secondary hidden font-medium sm:block">
              BOMACH Staff
            </span>
          </a>
          <a
            href="/login"
            className="text-label text-primary focus-visible:shadow-focus-ring rounded-control hover:bg-primary-subtle inline-flex min-h-10 items-center gap-2 px-3 font-semibold focus-visible:outline-none"
          >
            <ArrowLeft aria-hidden="true" className="size-4" />
            Staff sign in
          </a>
        </header>

        <article className="bg-surface border-border-subtle shadow-elevation-sm mt-5 overflow-hidden rounded-2xl border sm:mt-7">
          <div className="from-primary-subtle via-surface to-surface border-border-subtle border-b bg-gradient-to-br px-5 py-8 sm:px-9 sm:py-11">
            <p className="text-caption text-primary font-semibold tracking-[0.16em] uppercase">
              Bomach Group of Company
            </p>
            <div className="mt-3 flex items-start gap-4">
              <span className="bg-primary text-text-inverse hidden size-12 shrink-0 items-center justify-center rounded-2xl sm:flex">
                <ShieldCheck aria-hidden="true" className="size-6" />
              </span>
              <div className="min-w-0">
                <h1 className="text-h1 text-text-primary text-3xl font-semibold tracking-tight sm:text-4xl">
                  BOMACH Staff Privacy Policy
                </h1>
                <p className="text-body-md text-text-secondary mt-3 max-w-3xl leading-7">
                  This notice explains how Bomach Group handles staff and device information when
                  you use the BOMACH Staff mobile application and its attendance and work-report
                  features.
                </p>
              </div>
            </div>
          </div>

          <div className="grid gap-7 px-5 py-6 sm:px-9 sm:py-8 lg:grid-cols-[220px_minmax(0,1fr)] lg:gap-10">
            <aside className="lg:sticky lg:top-6 lg:self-start">
              <nav
                aria-label="Privacy policy sections"
                className="bg-background border-border-subtle rounded-xl border p-4"
              >
                <p className="text-caption text-text-muted mb-2 font-semibold tracking-wide uppercase">
                  On this page
                </p>
                <ul className="space-y-1">
                  {sections.map((section) => (
                    <li key={section.id}>
                      <a
                        className="text-body-sm text-text-secondary hover:text-primary focus-visible:shadow-focus-ring block rounded-lg px-2 py-2 leading-5 focus-visible:outline-none"
                        href={`#${section.id}`}
                      >
                        {section.label}
                      </a>
                    </li>
                  ))}
                </ul>
              </nav>
              <p className="text-caption text-text-muted mt-4 px-1 leading-5">
                The app is intended for employees and authorised company personnel. Accounts are
                provided and managed by Bomach.
              </p>
            </aside>

            <div className="min-w-0">
              <div className="bg-primary-subtle border-primary/15 rounded-xl border p-4 sm:p-5">
                <div className="flex items-start gap-3">
                  <Fingerprint aria-hidden="true" className="text-primary mt-0.5 size-5 shrink-0" />
                  <p className="text-body-sm text-text-primary leading-6">
                    <strong>Some features use sensitive information.</strong> Face verification uses
                    a face image to create a numeric face template, and attendance checks can use
                    your device location. These features run when you choose the related staff
                    workflow and require the relevant device permission.
                  </p>
                </div>
              </div>

              <Section
                id="information"
                title="Information we use"
                icon={<UserRound aria-hidden="true" className="size-5" />}
              >
                <p>
                  BOMACH Staff uses information associated with your company account, such as your
                  name, work contact details, employee identifier, role, and account status. When
                  you sign in, the app processes authentication and session information so it can
                  securely connect you to your employee workspace. Session credentials are stored
                  using the device secure-storage facility.
                </p>
                <p>
                  The app also processes information you choose to submit, including attendance
                  actions, work-location requests, work reports, survey or site details, and related
                  notes and attachments.
                </p>
              </Section>

              <Section
                id="face-verification"
                title="Face verification"
                icon={<Fingerprint aria-hidden="true" className="size-5" />}
              >
                <p>
                  If face verification is enabled for your account, the app captures an image for
                  enrollment or an attendance check and sends it to Bomach’s configured face
                  verification service for matching. The service returns a numeric face template;
                  Bomach stores that template with your staff account and uses it for later face
                  comparisons. Face information is used for staff identity and attendance checks,
                  not for advertising.
                </p>
                <p>
                  The face image is sent to the verification service for processing. The service
                  operator and its image-retention settings depend on Bomach’s production service
                  configuration. Contact Bomach using the details below for the current provider and
                  processing information. You can ask an authorised administrator to remove your
                  registered face template or raise a request with HR.
                </p>
              </Section>

              <Section
                id="location"
                title="Location information"
                icon={<MapPin aria-hidden="true" className="size-5" />}
              >
                <p>
                  When you start an attendance or work-location workflow that needs location
                  verification, the app requests foreground location access and sends the
                  coordinates to Bomach’s service. Coordinates are used to check proximity to an
                  approved work location and, where relevant, to associate a submitted record with
                  its location. The app does not request background location access.
                </p>
                <p>
                  You can manage location permission in your device settings. If you deny it, a
                  location-dependent attendance or work-location feature may not be available.
                </p>
              </Section>

              <Section
                id="files"
                title="Reports, photos, and documents"
                icon={<Camera aria-hidden="true" className="size-5" />}
              >
                <p>
                  If you attach a photo or document to a work report, the selected file and the
                  details you submit are uploaded to Bomach’s authorised application and file
                  services. They are used to create, review, and maintain company work records. Only
                  personnel with the appropriate work access should be able to view those records.
                </p>
                <p>
                  Please submit only material needed for your work and avoid including unrelated
                  personal or confidential information in report attachments.
                </p>
              </Section>

              <Section
                id="sharing"
                title="How information is shared"
                icon={<BellRing aria-hidden="true" className="size-5" />}
              >
                <p>
                  Information is available to authorised Bomach personnel who need it for employment
                  administration, attendance, work coordination, safety, or review. We may use
                  service providers to operate the app, process face matching, store submitted
                  files, and deliver notifications. Providers receive only information needed for
                  their service and are expected to protect it under applicable arrangements.
                </p>
                <p>
                  If you enable notifications, the app registers an installation identifier and
                  push-notification token with Bomach. Notifications are routed through Expo’s push
                  service and the platform provider (including Firebase Cloud Messaging on Android).
                  We do not sell staff information or use it to build advertising profiles. We may
                  also disclose information when required by law or to protect people, rights, and
                  systems.
                </p>
              </Section>

              <Section
                id="retention"
                title="Retention and your choices"
                icon={<LockKeyhole aria-hidden="true" className="size-5" />}
              >
                <p>
                  Bomach keeps account and work records for as long as needed to operate the
                  employment relationship, support attendance and business records, meet legal
                  obligations, and protect the service. Face templates are retained while face
                  verification remains enabled for your account and should be removed when that
                  registration is withdrawn, subject to any applicable legal or security
                  requirement. Exact retention periods depend on Bomach’s approved records schedule;
                  this notice does not set a fixed number of days or years.
                </p>
                <p>
                  The mobile app does not provide self-service account registration. Accounts are
                  issued by Bomach. To request access, correction, removal of face registration,
                  account deactivation, or deletion of eligible personal information, contact your
                  HR or account administrator, or email the privacy contact below. Some employment,
                  attendance, audit, or legal records may need to be retained after app access is
                  removed. We may ask you to verify your identity before acting on a request.
                </p>
              </Section>

              <Section
                id="security"
                title="Security and contact"
                icon={<ShieldCheck aria-hidden="true" className="size-5" />}
              >
                <p>
                  Bomach uses access controls and technical safeguards intended to protect
                  information. The app uses secure transport to production services and device
                  secure storage for session credentials. No method of storage or transmission can
                  be guaranteed completely secure; report a suspected privacy or security issue
                  promptly to Bomach.
                </p>
                <p>
                  The data controller for BOMACH Staff is Bomach Group of Company. For privacy
                  questions or requests, email{' '}
                  <a
                    className="text-primary focus-visible:shadow-focus-ring rounded-sm font-semibold underline underline-offset-4 focus-visible:outline-none"
                    href="mailto:bomachgroupmanagement@gmail.com?subject=BOMACH%20Staff%20privacy%20request"
                  >
                    bomachgroupmanagement@gmail.com
                  </a>{' '}
                  or contact your HR administrator. Please do not send your password or a face image
                  by email. We may update this notice when the app or its data practices change; the
                  current version will remain available at this public address.
                </p>
              </Section>
            </div>
          </div>
        </article>

        <footer className="text-caption text-text-muted px-1 py-5 text-center">
          Bomach Group of Company · BOMACH Staff Privacy Policy
        </footer>
      </div>
    </main>
  )
}
