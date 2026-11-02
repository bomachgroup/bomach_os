import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query'
import { Building2, Check, Clock3, ImagePlus, MapPin, Pencil, Upload, X } from 'lucide-react'
import { useState, type FormEvent, type ReactNode } from 'react'

import {
  companyDashboardApi,
  companyIdentityQueryKeys,
  type CompanyBrandingDto,
  type CompanySettingsChoice,
} from '@/modules/company/company-dashboard.api'
import { CompanyLogoImage } from '@/modules/company/components/company-logo-image'
import { authSessionQueryOptions, hasPermission } from '@/shared/auth/session'
import { presentError } from '@/shared/errors'
import { useToast } from '@/shared/feedback/use-toast'
import { DATA_FRESHNESS_MS } from '@/shared/query/freshness'
import { Alert } from '@/shared/ui/alert'
import { Button } from '@/shared/ui/button'
import { Card } from '@/shared/ui/card'
import { Dialog } from '@/shared/ui/dialog'
import { DropdownSelect, type DropdownSelectOption } from '@/shared/ui/dropdown-select'
import { EmptyState, SectionErrorState, Skeleton } from '@/shared/ui/feedback-states'
import { FormControl, TextArea, TextInput } from '@/shared/ui/form-control'
import { FormSection } from '@/shared/ui/form-section'
import { PageLayout } from '@/shared/ui/page-layout'
import { StatusChip } from '@/shared/ui/status-chip'
import { TimePickerField } from '@/shared/ui/time-picker-field'

type EditorSection = 'profile' | 'branding' | 'preferences' | null

interface ProfileDraft {
  company_name: string
  company_email: string
  company_phone: string
  company_addresses: string
  rc_number: string
  industry: string
}

interface BrandingDraft {
  company_slogan: string
  primary_color_code: string
  secondary_color_code: string
}

interface PreferencesDraft {
  default_currency: string
  language_preference: string
  time_zone: string
  punctuality_cutoff_time: string
  business_rules: string
}

const emptyProfile: ProfileDraft = {
  company_name: '',
  company_email: '',
  company_phone: '',
  company_addresses: '',
  rc_number: '',
  industry: '',
}

const defaultBranding: BrandingDraft = {
  company_slogan: '',
  primary_color_code: '#FE0000',
  secondary_color_code: '#3E4094',
}

const defaultPreferences: PreferencesDraft = {
  default_currency: 'NGN',
  language_preference: 'en-GB',
  time_zone: 'Africa/Lagos',
  punctuality_cutoff_time: '08:10',
  business_rules: '',
}

function SettingRow({
  label,
  value,
  icon,
}: {
  label: string
  value: string | null | undefined
  icon?: ReactNode
}) {
  return (
    <div className="border-border-subtle flex min-w-0 gap-3 border-b py-3 first:pt-0 last:border-b-0 last:pb-0">
      {icon ? <span className="text-text-muted mt-0.5 shrink-0">{icon}</span> : null}
      <div className="min-w-0 flex-1">
        <p className="text-caption text-text-secondary">{label}</p>
        <p className="text-body-sm text-text-primary mt-0.5 font-medium break-words">
          {value?.trim() || <span className="text-text-muted font-normal">Not provided</span>}
        </p>
      </div>
    </div>
  )
}

function SectionHeading({
  title,
  description,
  icon,
  onEdit,
  canEdit,
}: {
  title: string
  description: string
  icon: ReactNode
  onEdit: () => void
  canEdit: boolean
}) {
  return (
    <div className="flex min-w-0 items-start gap-3">
      <span className="bg-primary-subtle text-primary rounded-control flex size-10 shrink-0 items-center justify-center">
        {icon}
      </span>
      <div className="min-w-0 flex-1">
        <h2 className="text-label text-text-primary font-semibold">{title}</h2>
        <p className="text-caption text-text-secondary mt-0.5">{description}</p>
      </div>
      {canEdit ? (
        <Button
          variant="outline"
          size="sm"
          className="shrink-0"
          leadingIcon={<Pencil className="size-3.5" aria-hidden="true" />}
          onClick={onEdit}
        >
          Edit
        </Button>
      ) : null}
    </div>
  )
}

function LoadingCard() {
  return (
    <Card className="space-y-4 p-5">
      <div className="flex items-center gap-3">
        <Skeleton className="rounded-control size-10" />
        <div className="flex-1 space-y-2">
          <Skeleton className="h-4 w-40" />
          <Skeleton className="h-3 w-64 max-w-full" />
        </div>
      </div>
      <Skeleton className="h-24 w-full" />
    </Card>
  )
}

function optionList(choices: CompanySettingsChoice[] | undefined): DropdownSelectOption[] {
  return (choices ?? []).map(({ value, label }) => ({ value, label }))
}

function currencyLabel(value: string, choices: CompanySettingsChoice[] | undefined) {
  return choices?.find((choice) => choice.value === value)?.label ?? value
}

function shortTime(value: string | undefined) {
  return value?.slice(0, 5) || 'Not set'
}

export function CompanyProfilePage() {
  const queryClient = useQueryClient()
  const { showToast } = useToast()
  const sessionQuery = useQuery(authSessionQueryOptions())
  const session = sessionQuery.data
  const userId = session?.user.id ?? 0
  const canEdit = hasPermission(session?.permissions ?? {}, 'company_settings', 'update')
  const [activeEditor, setActiveEditor] = useState<EditorSection>(null)
  const [profileDraft, setProfileDraft] = useState<ProfileDraft>(emptyProfile)
  const [brandingDraft, setBrandingDraft] = useState<BrandingDraft>(defaultBranding)
  const [preferencesDraft, setPreferencesDraft] = useState<PreferencesDraft>(defaultPreferences)
  const [logoFile, setLogoFile] = useState<File | null>(null)
  const [removeLogo, setRemoveLogo] = useState(false)

  const profile = useQuery({
    queryKey: companyIdentityQueryKeys.profile(userId),
    queryFn: ({ signal }) => companyDashboardApi.profile(signal),
    enabled: Boolean(session),
    staleTime: DATA_FRESHNESS_MS.reference,
    refetchOnWindowFocus: true,
    refetchOnReconnect: true,
  })
  const branding = useQuery({
    queryKey: companyIdentityQueryKeys.branding(userId),
    queryFn: ({ signal }) => companyDashboardApi.branding(signal),
    enabled: Boolean(session),
    staleTime: DATA_FRESHNESS_MS.reference,
    refetchOnWindowFocus: true,
    refetchOnReconnect: true,
  })
  const preferences = useQuery({
    queryKey: companyIdentityQueryKeys.preferences(userId),
    queryFn: ({ signal }) => companyDashboardApi.preferences(signal),
    enabled: Boolean(session),
    staleTime: DATA_FRESHNESS_MS.reference,
    refetchOnWindowFocus: true,
    refetchOnReconnect: true,
  })
  const choices = useQuery({
    queryKey: companyIdentityQueryKeys.choices(userId),
    queryFn: ({ signal }) => companyDashboardApi.choices(signal),
    enabled: Boolean(session && activeEditor === 'preferences'),
    staleTime: DATA_FRESHNESS_MS.reference,
    refetchOnWindowFocus: true,
    refetchOnReconnect: true,
  })

  const profileSave = useMutation({
    mutationFn: companyDashboardApi.updateProfile,
    onSuccess: (saved) => {
      queryClient.setQueryData(companyIdentityQueryKeys.profile(userId), saved)
      setActiveEditor(null)
      showToast({ tone: 'success', title: 'Company details saved' })
    },
  })
  const brandingSave = useMutation({
    mutationFn: async (input: { draft: BrandingDraft; file: File | null; removeLogo: boolean }) => {
      const uploaded = input.file ? await companyDashboardApi.uploadLogo(input.file) : null
      const payload: Partial<CompanyBrandingDto> = {
        ...input.draft,
        ...(uploaded ? { company_logo: uploaded.url } : {}),
        ...(input.removeLogo ? { company_logo: null } : {}),
      }
      return companyDashboardApi.updateBranding(payload)
    },
    onSuccess: (saved) => {
      queryClient.setQueryData(companyIdentityQueryKeys.branding(userId), saved)
      setLogoFile(null)
      setRemoveLogo(false)
      setActiveEditor(null)
      showToast({ tone: 'success', title: 'Brand identity saved' })
    },
  })
  const preferencesSave = useMutation({
    mutationFn: companyDashboardApi.updatePreferences,
    onSuccess: (saved) => {
      queryClient.setQueryData(companyIdentityQueryKeys.preferences(userId), saved)
      setActiveEditor(null)
      showToast({ tone: 'success', title: 'Operating defaults saved' })
    },
  })

  function openEditor(section: Exclude<EditorSection, null>) {
    if (section === 'profile') {
      const data = profile.data
      setProfileDraft(
        data?.is_configured
          ? {
              company_name: data.company_name,
              company_email: data.company_email,
              company_phone: data.company_phone,
              company_addresses: data.company_addresses,
              rc_number: data.rc_number,
              industry: data.industry,
            }
          : emptyProfile,
      )
      profileSave.reset()
    }
    if (section === 'branding') {
      setBrandingDraft({
        company_slogan: branding.data?.company_slogan ?? '',
        primary_color_code: branding.data?.primary_color_code ?? defaultBranding.primary_color_code,
        secondary_color_code:
          branding.data?.secondary_color_code ?? defaultBranding.secondary_color_code,
      })
      setLogoFile(null)
      setRemoveLogo(false)
      brandingSave.reset()
    }
    if (section === 'preferences') {
      setPreferencesDraft({
        default_currency: preferences.data?.default_currency ?? defaultPreferences.default_currency,
        language_preference:
          preferences.data?.language_preference ?? defaultPreferences.language_preference,
        time_zone: preferences.data?.time_zone ?? defaultPreferences.time_zone,
        punctuality_cutoff_time: shortTime(
          preferences.data?.punctuality_cutoff_time ?? defaultPreferences.punctuality_cutoff_time,
        ),
        business_rules: preferences.data?.business_rules ?? '',
      })
      preferencesSave.reset()
    }
    setActiveEditor(section)
  }

  function submitProfile(event: FormEvent<HTMLFormElement>) {
    event.preventDefault()
    profileSave.mutate({
      company_name: profileDraft.company_name.trim(),
      company_email: profileDraft.company_email.trim(),
      company_phone: profileDraft.company_phone.trim(),
      company_addresses: profileDraft.company_addresses.trim(),
      rc_number: profileDraft.rc_number.trim(),
      industry: profileDraft.industry.trim(),
    })
  }

  function submitBranding(event: FormEvent<HTMLFormElement>) {
    event.preventDefault()
    brandingSave.mutate({
      draft: brandingDraft,
      file: logoFile,
      removeLogo: removeLogo && !logoFile,
    })
  }

  function submitPreferences(event: FormEvent<HTMLFormElement>) {
    event.preventDefault()
    preferencesSave.mutate({
      default_currency: preferencesDraft.default_currency,
      language_preference: preferencesDraft.language_preference,
      time_zone: preferencesDraft.time_zone,
      punctuality_cutoff_time: preferencesDraft.punctuality_cutoff_time,
      business_rules: preferencesDraft.business_rules.trim(),
    })
  }

  const profileData = profile.data
  const brandingData = branding.data
  const preferencesData = preferences.data
  const configured = profileData?.is_configured === true
  const companyName = profileData
    ? configured
      ? profileData.company_name
      : 'Company profile setup'
    : profile.isPending
      ? 'Loading company profile…'
      : 'Company profile'
  const currentSave =
    activeEditor === 'profile'
      ? profileSave
      : activeEditor === 'branding'
        ? brandingSave
        : activeEditor === 'preferences'
          ? preferencesSave
          : null
  const formError = currentSave?.error ? presentError(currentSave.error, 'form-submit') : null

  return (
    <PageLayout
      title="Company profile"
      subtitle="Manage the company identity and operating defaults used across BOMACH OS."
      leading={<Building2 className="size-5" aria-hidden="true" />}
    >
      <div className="mx-auto max-w-5xl space-y-5">
        <Card className="from-primary-subtle/70 via-surface to-surface overflow-hidden bg-gradient-to-br p-0">
          <div className="tablet:p-6 flex min-w-0 flex-col gap-5 p-4">
            <div className="flex min-w-0 items-center gap-4">
              <div className="border-border-subtle bg-surface rounded-surface shadow-elevation-sm flex size-16 shrink-0 items-center justify-center overflow-hidden border">
                {brandingData?.company_logo ? (
                  <CompanyLogoImage
                    src={brandingData.company_logo}
                    alt={`${companyName} logo`}
                    className="size-full object-contain p-2"
                    fallback={
                      <span role="img" aria-label={`${companyName} logo`}>
                        <Building2 className="text-primary size-7" aria-hidden="true" />
                      </span>
                    }
                  />
                ) : (
                  <Building2 className="text-primary size-7" aria-hidden="true" />
                )}
              </div>
              <div className="min-w-0 flex-1">
                <div className="tablet:flex-row tablet:items-center tablet:gap-2 flex min-w-0 flex-col items-start gap-1">
                  <h1 className="text-h2 text-text-primary min-w-0 font-semibold break-words">
                    {companyName}
                  </h1>
                  {profileData ? (
                    <StatusChip
                      dense
                      label={configured ? 'Configured' : 'Setup needed'}
                      tone={configured ? 'success' : 'warning'}
                    />
                  ) : null}
                </div>
                <p className="text-body-sm text-text-secondary mt-1">
                  {configured
                    ? brandingData?.company_slogan || 'Company identity and operating information'
                    : 'Add verified company details to complete this workspace identity.'}
                </p>
              </div>
            </div>
          </div>
        </Card>

        <section aria-label="Company details">
          <Card className="tablet:p-5 space-y-5 p-4">
            <SectionHeading
              title="Company details"
              description="Legal identity, registration, and contact information."
              icon={<Building2 className="size-5" aria-hidden="true" />}
              canEdit={canEdit && configured}
              onEdit={() => openEditor('profile')}
            />
            {profile.isPending && !profileData ? (
              <div className="space-y-3">
                <Skeleton className="h-4 w-3/4" />
                <Skeleton className="h-4 w-2/3" />
                <Skeleton className="h-4 w-1/2" />
              </div>
            ) : profileData?.is_configured ? (
              <>
                {profile.isError ? (
                  <Alert tone="warning" role="status" className="text-caption">
                    Showing the last saved details. The latest version could not be refreshed.
                  </Alert>
                ) : null}
                <div className="tablet:grid-cols-2 grid min-w-0 gap-x-8 gap-y-4">
                  <SettingRow label="Company name" value={profileData.company_name} />
                  <SettingRow label="Company email" value={profileData.company_email} />
                  <SettingRow label="Phone" value={profileData.company_phone} />
                  <SettingRow label="Industry" value={profileData.industry} />
                  <SettingRow label="Registration number" value={profileData.rc_number} />
                  <SettingRow
                    label="Registered address"
                    value={profileData.company_addresses}
                    icon={<MapPin className="size-4" aria-hidden="true" />}
                  />
                </div>
              </>
            ) : profile.isError ? (
              <SectionErrorState
                title="Company details could not be loaded"
                error={profile.error}
                onRetry={() => void profile.refetch()}
              />
            ) : (
              <div className="bg-surface-muted rounded-control px-4 py-4">
                <p className="text-label text-text-primary font-medium">
                  Company identity has not been configured
                </p>
                <p className="text-caption text-text-secondary mt-1">
                  Placeholder values are hidden until a real company name and email are saved.
                </p>
                {canEdit ? (
                  <Button
                    size="sm"
                    className="mt-3"
                    leadingIcon={<Pencil className="size-3.5" aria-hidden="true" />}
                    onClick={() => openEditor('profile')}
                  >
                    Set up company details
                  </Button>
                ) : null}
              </div>
            )}
          </Card>
        </section>

        <section aria-label="Brand identity">
          <Card className="tablet:p-5 space-y-5 p-4">
            <SectionHeading
              title="Brand identity"
              description="The logo, slogan, and colors used to represent the company."
              icon={<ImagePlus className="size-5" aria-hidden="true" />}
              canEdit={canEdit}
              onEdit={() => openEditor('branding')}
            />
            {branding.isPending && !brandingData ? (
              <div className="flex items-center gap-4">
                <Skeleton className="rounded-control size-16" />
                <div className="flex-1 space-y-2">
                  <Skeleton className="h-4 w-40" />
                  <Skeleton className="h-4 w-56 max-w-full" />
                </div>
              </div>
            ) : brandingData ? (
              <>
                {branding.isError ? (
                  <Alert tone="warning" role="status" className="text-caption">
                    Showing the last saved brand identity. Refresh to check for updates.
                  </Alert>
                ) : null}
                <div className="tablet:flex-row tablet:items-center flex min-w-0 flex-col gap-5">
                  <div className="border-border-subtle bg-surface-muted rounded-control flex size-20 shrink-0 items-center justify-center overflow-hidden border">
                    {brandingData.company_logo ? (
                      <CompanyLogoImage
                        src={brandingData.company_logo}
                        alt="Company logo"
                        className="size-full object-contain p-2"
                        fallback={
                          <span role="img" aria-label="Company logo">
                            <Building2 className="text-text-muted size-7" aria-hidden="true" />
                          </span>
                        }
                      />
                    ) : (
                      <Building2 className="text-text-muted size-7" aria-hidden="true" />
                    )}
                  </div>
                  <div className="tablet:grid-cols-2 grid min-w-0 flex-1 gap-4">
                    <SettingRow label="Company slogan" value={brandingData.company_slogan} />
                    <div className="flex min-w-0 items-center gap-4">
                      <div className="min-w-0">
                        <p className="text-caption text-text-secondary">Brand colors</p>
                        <div className="mt-2 flex flex-wrap items-center gap-2">
                          {[brandingData.primary_color_code, brandingData.secondary_color_code].map(
                            (color, index) => (
                              <span
                                key={`${index}-${color}`}
                                className="border-border-subtle rounded-pill bg-surface inline-flex items-center gap-2 border px-2.5 py-1"
                              >
                                <span
                                  className="border-border-subtle size-4 rounded-full border"
                                  style={{ backgroundColor: color }}
                                  aria-hidden="true"
                                />
                                <span className="text-overline text-text-secondary uppercase">
                                  {color}
                                </span>
                              </span>
                            ),
                          )}
                        </div>
                      </div>
                    </div>
                  </div>
                </div>
              </>
            ) : branding.isError ? (
              <SectionErrorState
                title="Brand identity could not be loaded"
                error={branding.error}
                onRetry={() => void branding.refetch()}
              />
            ) : (
              <EmptyState
                title="No brand details available"
                description="Brand settings will appear here when available."
              />
            )}
          </Card>
        </section>

        <section aria-label="Operating defaults">
          <Card className="tablet:p-5 space-y-5 p-4">
            <SectionHeading
              title="Operating defaults"
              description="Company-wide defaults for supported language, time, and attendance settings."
              icon={<Clock3 className="size-5" aria-hidden="true" />}
              canEdit={canEdit}
              onEdit={() => openEditor('preferences')}
            />
            {preferences.isPending && !preferencesData ? (
              <div className="tablet:grid-cols-2 grid gap-4">
                <LoadingCard />
                <LoadingCard />
              </div>
            ) : preferencesData ? (
              <>
                {preferences.isError ? (
                  <Alert tone="warning" role="status" className="text-caption">
                    Showing the last saved defaults. The latest version could not be refreshed.
                  </Alert>
                ) : null}
                <div className="tablet:grid-cols-2 grid min-w-0 gap-x-8 gap-y-4">
                  <SettingRow
                    label="Default currency"
                    value={currencyLabel(
                      preferencesData.default_currency,
                      choices.data?.currencies,
                    )}
                  />
                  <SettingRow label="Language" value={preferencesData.language_preference} />
                  <SettingRow
                    label="Time zone"
                    value={preferencesData.time_zone || 'Africa/Lagos'}
                  />
                  <SettingRow
                    label="Punctuality cutoff"
                    value={shortTime(preferencesData.punctuality_cutoff_time)}
                    icon={<Clock3 className="size-4" aria-hidden="true" />}
                  />
                  <div className="tablet:col-span-2">
                    <SettingRow label="Business rules" value={preferencesData.business_rules} />
                  </div>
                </div>
              </>
            ) : preferences.isError ? (
              <SectionErrorState
                title="Operating defaults could not be loaded"
                error={preferences.error}
                onRetry={() => void preferences.refetch()}
              />
            ) : (
              <EmptyState
                title="Operating defaults are unavailable"
                description="Supported company defaults will appear here when they can be loaded."
              />
            )}
          </Card>
        </section>
      </div>

      <Dialog
        open={activeEditor === 'profile'}
        onOpenChange={(open) => setActiveEditor(open ? 'profile' : null)}
        title={profileData?.is_configured ? 'Edit company details' : 'Set up company details'}
        description="Update the company’s legal identity and contact information."
        size="md"
        fitContent
        footer={
          <>
            <Button variant="outline" onClick={() => setActiveEditor(null)}>
              Cancel
            </Button>
            <Button
              type="submit"
              form="company-profile-form"
              isLoading={profileSave.isPending}
              leadingIcon={!profileSave.isPending ? <Check className="size-4" /> : undefined}
            >
              Save details
            </Button>
          </>
        }
      >
        <form id="company-profile-form" className="space-y-4" onSubmit={submitProfile}>
          {formError ? (
            <Alert tone="danger" role="status" title={formError.title}>
              {formError.message}
            </Alert>
          ) : null}
          <FormSection className="space-y-4">
            <div>
              <h3 className="text-label font-semibold">Company identity</h3>
              <p className="text-caption text-text-secondary mt-1">
                Legal registration and contact details.
              </p>
            </div>
            <div className="tablet:grid-cols-2 grid gap-4">
              <FormControl id="company-profile-name" label="Company name" required>
                <TextInput
                  value={profileDraft.company_name}
                  onChange={(event) =>
                    setProfileDraft((draft) => ({ ...draft, company_name: event.target.value }))
                  }
                  autoComplete="organization"
                  maxLength={255}
                  required
                />
              </FormControl>
              <FormControl id="company-profile-email" label="Company email" required>
                <TextInput
                  type="email"
                  value={profileDraft.company_email}
                  onChange={(event) =>
                    setProfileDraft((draft) => ({ ...draft, company_email: event.target.value }))
                  }
                  autoComplete="email"
                  maxLength={254}
                  required
                />
              </FormControl>
              <FormControl id="company-profile-industry" label="Industry">
                <TextInput
                  value={profileDraft.industry}
                  onChange={(event) =>
                    setProfileDraft((draft) => ({ ...draft, industry: event.target.value }))
                  }
                  maxLength={150}
                  placeholder="e.g. Construction"
                />
              </FormControl>
              <FormControl id="company-profile-registration" label="Registration number">
                <TextInput
                  value={profileDraft.rc_number}
                  onChange={(event) =>
                    setProfileDraft((draft) => ({ ...draft, rc_number: event.target.value }))
                  }
                  maxLength={50}
                  placeholder="e.g. RC1234567"
                />
              </FormControl>
              <FormControl id="company-profile-phone" label="Company phone">
                <TextInput
                  type="tel"
                  value={profileDraft.company_phone}
                  onChange={(event) =>
                    setProfileDraft((draft) => ({ ...draft, company_phone: event.target.value }))
                  }
                  autoComplete="tel"
                  maxLength={20}
                />
              </FormControl>
              <FormControl
                id="company-profile-address"
                label="Registered address"
                className="tablet:col-span-2"
              >
                <TextArea
                  rows={3}
                  value={profileDraft.company_addresses}
                  onChange={(event) =>
                    setProfileDraft((draft) => ({
                      ...draft,
                      company_addresses: event.target.value,
                    }))
                  }
                  autoComplete="street-address"
                />
              </FormControl>
            </div>
          </FormSection>
        </form>
      </Dialog>

      <Dialog
        open={activeEditor === 'branding'}
        onOpenChange={(open) => setActiveEditor(open ? 'branding' : null)}
        title="Edit brand identity"
        description="Keep the company logo, slogan, and colors consistent."
        size="md"
        fitContent
        footer={
          <>
            <Button variant="outline" onClick={() => setActiveEditor(null)}>
              Cancel
            </Button>
            <Button
              type="submit"
              form="company-branding-form"
              isLoading={brandingSave.isPending}
              leadingIcon={!brandingSave.isPending ? <Check className="size-4" /> : undefined}
            >
              Save brand identity
            </Button>
          </>
        }
      >
        <form id="company-branding-form" className="space-y-4" onSubmit={submitBranding}>
          {formError ? (
            <Alert tone="danger" role="status" title={formError.title}>
              {formError.message}
            </Alert>
          ) : null}
          <FormSection className="space-y-4">
            <div>
              <h3 className="text-label font-semibold">Brand assets</h3>
              <p className="text-caption text-text-secondary mt-1">
                Choose a logo and set the company slogan and brand colors.
              </p>
            </div>
            <div className="bg-surface border-border-subtle rounded-control flex min-w-0 flex-wrap items-center gap-3 border p-3">
              <div className="border-border-subtle bg-surface rounded-control flex size-14 shrink-0 items-center justify-center overflow-hidden border">
                {brandingData?.company_logo && !removeLogo ? (
                  <CompanyLogoImage
                    src={brandingData.company_logo}
                    alt="Current company logo"
                    className="size-full object-contain p-1"
                    fallback={
                      <span role="img" aria-label="Current company logo">
                        <Building2 className="text-text-muted size-5" aria-hidden="true" />
                      </span>
                    }
                  />
                ) : (
                  <Building2 className="text-text-muted size-5" aria-hidden="true" />
                )}
              </div>
              <div className="min-w-0 flex-1">
                <p className="text-label text-text-primary font-medium">Company logo</p>
                <p className="text-caption text-text-secondary mt-0.5 truncate">
                  {logoFile?.name ??
                    (removeLogo ? 'Logo will be removed' : 'PNG, JPG, or SVG image')}
                </p>
              </div>
              <label className="rounded-control border-border-strong bg-surface text-caption focus-within:shadow-focus-ring hover:bg-surface-muted inline-flex min-h-9 cursor-pointer items-center gap-2 border px-3 font-semibold">
                <Upload className="size-3.5" aria-hidden="true" />
                Choose file
                <input
                  type="file"
                  accept="image/*"
                  className="sr-only"
                  onChange={(event) => {
                    const nextFile = event.currentTarget.files?.[0] ?? null
                    setLogoFile(nextFile)
                    if (nextFile) setRemoveLogo(false)
                  }}
                />
              </label>
              {brandingData?.company_logo && !removeLogo ? (
                <Button
                  variant="ghost"
                  size="icon"
                  aria-label="Remove company logo"
                  onClick={() => {
                    setLogoFile(null)
                    setRemoveLogo(true)
                  }}
                >
                  <X className="size-4" aria-hidden="true" />
                </Button>
              ) : null}
            </div>
            <FormControl id="company-branding-slogan" label="Company slogan">
              <TextInput
                value={brandingDraft.company_slogan}
                onChange={(event) =>
                  setBrandingDraft((draft) => ({ ...draft, company_slogan: event.target.value }))
                }
                maxLength={255}
                placeholder="A short line that represents the company"
              />
            </FormControl>
            <div className="tablet:grid-cols-2 grid gap-4">
              <FormControl id="company-branding-primary" label="Primary color">
                <TextInput
                  type="color"
                  value={brandingDraft.primary_color_code}
                  onChange={(event) =>
                    setBrandingDraft((draft) => ({
                      ...draft,
                      primary_color_code: event.target.value,
                    }))
                  }
                  className="h-12 cursor-pointer p-1.5"
                />
              </FormControl>
              <FormControl id="company-branding-secondary" label="Secondary color">
                <TextInput
                  type="color"
                  value={brandingDraft.secondary_color_code}
                  onChange={(event) =>
                    setBrandingDraft((draft) => ({
                      ...draft,
                      secondary_color_code: event.target.value,
                    }))
                  }
                  className="h-12 cursor-pointer p-1.5"
                />
              </FormControl>
            </div>
          </FormSection>
        </form>
      </Dialog>

      <Dialog
        open={activeEditor === 'preferences'}
        onOpenChange={(open) => setActiveEditor(open ? 'preferences' : null)}
        title="Edit operating defaults"
        description="Set the defaults used in company operating information."
        size="md"
        fitContent
        footer={
          <>
            <Button variant="outline" onClick={() => setActiveEditor(null)}>
              Cancel
            </Button>
            <Button
              type="submit"
              form="company-preferences-form"
              isLoading={preferencesSave.isPending}
              disabled={choices.isError || !choices.data}
              leadingIcon={!preferencesSave.isPending ? <Check className="size-4" /> : undefined}
            >
              Save defaults
            </Button>
          </>
        }
      >
        <form id="company-preferences-form" className="space-y-4" onSubmit={submitPreferences}>
          {formError ? (
            <Alert tone="danger" role="status" title={formError.title}>
              {formError.message}
            </Alert>
          ) : null}
          {choices.isPending && !choices.data ? (
            <div className="space-y-3" aria-live="polite">
              <Skeleton className="h-12 w-full" />
              <Skeleton className="h-12 w-full" />
              <p className="text-caption text-text-secondary">Loading supported choices…</p>
            </div>
          ) : choices.isError && !choices.data ? (
            <SectionErrorState
              title="Supported choices could not be loaded"
              error={choices.error}
              onRetry={() => void choices.refetch()}
            />
          ) : (
            <FormSection className="space-y-4">
              <div>
                <h3 className="text-label font-semibold">Operating defaults</h3>
                <p className="text-caption text-text-secondary mt-1">
                  Set the standard currency, language, and time rules for this company.
                </p>
              </div>
              <div className="tablet:grid-cols-2 grid gap-4">
                <FormControl id="company-default-currency" label="Default currency" required>
                  <DropdownSelect
                    value={preferencesDraft.default_currency}
                    options={optionList(choices.data?.currencies)}
                    onChange={(value) =>
                      setPreferencesDraft((draft) => ({ ...draft, default_currency: value }))
                    }
                    searchable
                    searchPlaceholder="Search currencies"
                    required
                  />
                </FormControl>
                <FormControl id="company-default-language" label="Language" required>
                  <DropdownSelect
                    value={preferencesDraft.language_preference}
                    options={optionList(choices.data?.languages)}
                    onChange={(value) =>
                      setPreferencesDraft((draft) => ({ ...draft, language_preference: value }))
                    }
                    required
                  />
                </FormControl>
                <FormControl
                  id="company-default-time-zone"
                  label="Time zone"
                  description="Saved for company settings; other pages keep their current time-zone behavior."
                  className="tablet:col-span-2"
                  required
                >
                  <DropdownSelect
                    value={preferencesDraft.time_zone}
                    options={optionList(choices.data?.time_zones)}
                    onChange={(value) =>
                      setPreferencesDraft((draft) => ({ ...draft, time_zone: value }))
                    }
                    searchable
                    searchPlaceholder="Search IANA time zones"
                    required
                  />
                </FormControl>
                <FormControl
                  id="company-punctuality-cutoff"
                  label="Punctuality cutoff"
                  description="Clock-ins at or before this time are considered on time."
                  className="tablet:col-span-2"
                  required
                >
                  <TimePickerField
                    value={preferencesDraft.punctuality_cutoff_time}
                    onValueChange={(value) =>
                      setPreferencesDraft((draft) => ({
                        ...draft,
                        punctuality_cutoff_time: value,
                      }))
                    }
                    required
                  />
                </FormControl>
                <FormControl
                  id="company-business-rules"
                  label="Business rules"
                  description="Optional operating guidance for the company."
                  className="tablet:col-span-2"
                >
                  <TextArea
                    rows={3}
                    value={preferencesDraft.business_rules}
                    onChange={(event) =>
                      setPreferencesDraft((draft) => ({
                        ...draft,
                        business_rules: event.target.value,
                      }))
                    }
                  />
                </FormControl>
              </div>
            </FormSection>
          )}
        </form>
      </Dialog>
    </PageLayout>
  )
}
