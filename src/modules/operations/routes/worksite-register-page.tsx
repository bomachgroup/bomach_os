import { useEffect, useState, type FormEvent } from 'react'
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query'
import { Link, useNavigate, useParams, useSearch } from '@tanstack/react-router'
import { ArrowRight, MapPin, Plus, Search } from 'lucide-react'

import { authSessionQueryOptions, hasPermission } from '@/shared/auth/session'
import { isApiError } from '@/shared/api/api-error'
import { useToast } from '@/shared/feedback/use-toast'
import { Button } from '@/shared/ui/button'
import { Card } from '@/shared/ui/card'
import { Dialog } from '@/shared/ui/dialog'
import { DropdownSelect } from '@/shared/ui/dropdown-select'
import { EmptyState, ErrorState, Skeleton } from '@/shared/ui/feedback-states'
import { FormControl, TextArea, TextInput } from '@/shared/ui/form-control'
import { PageBackLinkContent, pageBackLinkClassName } from '@/shared/ui/page-back-link'
import { PageLayout } from '@/shared/ui/page-layout'
import { StatusChip } from '@/shared/ui/status-chip'
import { operationsRegisterKeys, operationsRegisterQueries } from '../operations-registers.queries'
import { operationsRegistersApi, type OperationsWorksite } from '../operations-registers.api'
import { projectQueryKeys, type ProjectListParams } from '../projects.api'
import { projectQueries } from '../projects.queries'
import type { WorksitesSearch } from '../operations-registers.search'

const PAGE_SIZE = 10
const statuses = [
  { value: 'all', label: 'All statuses' },
  { value: 'setup', label: 'Setup' },
  { value: 'active', label: 'Active' },
  { value: 'inactive', label: 'Inactive' },
  { value: 'completed', label: 'Completed' },
]

function SiteSearch({ value }: { value: string }) {
  const navigate = useNavigate()
  const [draft, setDraft] = useState(value)
  useEffect(() => {
    const search = draft.trim().slice(0, 120)
    if (search === value) return
    const timer = window.setTimeout(() => {
      void navigate({
        to: '/works/worksite',
        search: (previous: WorksitesSearch) => ({ ...previous, search, page: 1 }),
        replace: true,
        resetScroll: false,
      })
    }, 250)
    return () => window.clearTimeout(timer)
  }, [draft, navigate, value])
  return (
    <label
      className="text-control-label text-text-secondary block space-y-1.5 font-bold"
      htmlFor="site-search"
    >
      Search worksites
      <span className="relative block">
        <Search
          className="text-text-muted absolute top-1/2 left-3 size-4 -translate-y-1/2"
          aria-hidden="true"
        />
        <TextInput
          id="site-search"
          type="search"
          value={draft}
          maxLength={120}
          className="pl-9"
          placeholder="Site name or location"
          onChange={(event) => setDraft(event.target.value)}
        />
      </span>
    </label>
  )
}

export function WorksiteRegisterPage() {
  const search = useSearch({ strict: false }) as WorksitesSearch
  return <WorksiteRegisterContent search={search} />
}

function WorksiteRegisterContent({ search }: { search: WorksitesSearch }) {
  const navigate = useNavigate()
  const client = useQueryClient()
  const toast = useToast()
  const sessionQuery = useQuery(authSessionQueryOptions())
  const session = sessionQuery.data
  const userId = session?.user.id ?? 0
  const employeeId = session?.employee.employee_id ?? ''
  const [formOpen, setFormOpen] = useState(false)
  const [editing, setEditing] = useState<OperationsWorksite | null>(null)
  const [deleteTarget, setDeleteTarget] = useState<OperationsWorksite | null>(null)
  const [deleteConflict, setDeleteConflict] = useState('')
  const [formError, setFormError] = useState('')
  const params = {
    limit: PAGE_SIZE,
    offset: (search.page - 1) * PAGE_SIZE,
    search: search.search,
    status: search.status === 'all' ? '' : search.status,
    project_id: search.projectId,
  }
  const sites = useQuery({
    ...operationsRegisterQueries.worksites(userId, employeeId, params),
    enabled: Boolean(session && hasPermission(session.permissions, 'worksites', 'list')),
  })
  const projectParams: ProjectListParams = {
    limit: 100,
    offset: 0,
    search: '',
    status: '',
    priority: '',
    archived: false,
  }
  const projectOptions = useQuery({
    ...projectQueries.list(userId, employeeId, projectParams),
    enabled: Boolean(session && hasPermission(session.permissions, 'projects', 'list')),
  })
  const canCreate = Boolean(session && hasPermission(session.permissions, 'worksites', 'create'))
  const canView = Boolean(session && hasPermission(session.permissions, 'worksites', 'view'))
  const canUpdate = Boolean(session && hasPermission(session.permissions, 'worksites', 'update'))
  const canDelete = Boolean(session && hasPermission(session.permissions, 'worksites', 'delete'))
  const save = useMutation({
    mutationFn: async (input: {
      project_id: number | null
      name: string
      location: string
      status: string
      description: string | null
    }) =>
      editing
        ? operationsRegistersApi.updateWorksite(editing.id, input)
        : operationsRegistersApi.createWorksite(input),
    onSuccess: async (site) => {
      await Promise.all([
        client.invalidateQueries({
          queryKey: operationsRegisterKeys.lists(userId, employeeId, 'worksites'),
        }),
        client.invalidateQueries({ queryKey: projectQueryKeys.all }),
      ])
      setFormOpen(false)
      setEditing(null)
      toast.showToast({
        title: editing ? 'Worksite updated' : 'Worksite created',
        description: `${site.name} is saved in the worksite register.`,
        tone: 'success',
      })
    },
    onError: (error) =>
      setFormError(error instanceof Error ? error.message : 'The worksite could not be saved.'),
  })
  const remove = useMutation({
    mutationFn: (site: OperationsWorksite) => operationsRegistersApi.removeWorksite(site.id),
    onSuccess: async () => {
      await Promise.all([
        client.invalidateQueries({
          queryKey: operationsRegisterKeys.lists(userId, employeeId, 'worksites'),
        }),
        client.invalidateQueries({ queryKey: projectQueryKeys.all }),
      ])
      setDeleteTarget(null)
      toast.showToast({
        title: 'Worksite deleted',
        description: 'The unused worksite was removed.',
        tone: 'success',
      })
    },
    onError: (error) => {
      if (isApiError(error) && error.status === 409) {
        setDeleteConflict(error.message)
        return
      }
      setDeleteTarget(null)
      toast.showToast({
        title: 'Worksite could not be deleted',
        description: error instanceof Error ? error.message : 'Try again in a moment.',
        tone: 'danger',
      })
    },
  })
  const markInactive = useMutation({
    mutationFn: (site: OperationsWorksite) =>
      operationsRegistersApi.updateWorksite(site.id, { status: 'inactive' }),
    onSuccess: async (site) => {
      await Promise.all([
        client.invalidateQueries({
          queryKey: operationsRegisterKeys.lists(userId, employeeId, 'worksites'),
        }),
        client.invalidateQueries({ queryKey: projectQueryKeys.all }),
      ])
      setDeleteTarget(null)
      setDeleteConflict('')
      toast.showToast({
        title: 'Worksite marked inactive',
        description: `${site.name} remains available in operational history.`,
        tone: 'success',
      })
    },
    onError: (error) =>
      toast.showToast({
        title: 'Worksite could not be updated',
        description: error instanceof Error ? error.message : 'Try again in a moment.',
        tone: 'danger',
      }),
  })

  function change(patch: Partial<WorksitesSearch>) {
    void navigate({
      to: '/works/worksite',
      search: (previous: WorksitesSearch) => ({ ...previous, ...patch }),
      resetScroll: false,
    })
  }
  function startCreate() {
    setEditing(null)
    setFormError('')
    setFormOpen(true)
  }

  return (
    <PageLayout
      title="Worksites"
      subtitle="Manage operational locations and their project delivery context."
      actionsInline
      actions={
        canCreate ? (
          <Button size="sm" leadingIcon={<Plus className="size-4" />} onClick={startCreate}>
            <span className="hidden min-[480px]:inline">New worksite</span>
            <span className="min-[480px]:hidden">Add</span>
          </Button>
        ) : null
      }
    >
      <div className="space-y-5">
        <Card className="space-y-4">
          <div className="flex flex-wrap items-end justify-between gap-3">
            <div>
              <p className="text-overline text-primary font-semibold">Operations register</p>
              <h2 className="text-h2 text-text-primary mt-1 font-semibold">Worksite directory</h2>
              <p className="text-body-sm text-text-secondary mt-1">
                {sites.data?.count ?? '—'} locations in your access scope
              </p>
            </div>
            <div className="tablet:w-auto tablet:min-w-52 w-full">
              <DropdownSelect
                label="Status"
                value={search.status}
                options={statuses}
                onChange={(status) => change({ status, page: 1 })}
              />
            </div>
          </div>
          <div className="tablet:grid-cols-[minmax(0,1fr)_minmax(14rem,0.65fr)] grid gap-3">
            <SiteSearch key={search.search} value={search.search} />
            <DropdownSelect
              label="Project"
              value={String(search.projectId ?? '')}
              options={[
                { value: '', label: 'All projects' },
                ...(projectOptions.data?.items ?? []).map((project) => ({
                  value: String(project.id),
                  label: `${project.short_code} · ${project.name}`,
                })),
              ]}
              onChange={(value) => change({ projectId: value ? Number(value) : null, page: 1 })}
              disabled={!projectOptions.data}
            />
          </div>
        </Card>

        {sites.isPending ? (
          <div role="status" aria-label="Loading worksites" className="space-y-3">
            <Skeleton variant="card" className="h-40" />
            <Skeleton variant="card" className="h-40" />
          </div>
        ) : sites.isError ? (
          <ErrorState
            title="Worksites could not load"
            description="The register could not be refreshed."
            error={sites.error}
            action={
              <Button variant="outline" onClick={() => void sites.refetch()}>
                Try again
              </Button>
            }
          />
        ) : !sites.data?.items.length ? (
          <Card>
            <EmptyState
              title="No worksites match this view"
              description="Adjust the filters or add an operational location."
              action={
                canCreate ? (
                  <Button onClick={startCreate} leadingIcon={<Plus className="size-4" />}>
                    New worksite
                  </Button>
                ) : undefined
              }
            />
          </Card>
        ) : (
          <section aria-label="Worksite records" className="space-y-3">
            {sites.data.items.map((site) => (
              <WorksiteCard
                key={site.id}
                site={site}
                canView={canView}
                canUpdate={canUpdate}
                canDelete={canDelete}
                onEdit={() => {
                  setEditing(site)
                  setFormError('')
                  setFormOpen(true)
                }}
                onDelete={() => {
                  setDeleteConflict('')
                  setDeleteTarget(site)
                }}
              />
            ))}
          </section>
        )}

        {sites.data && sites.data.count > PAGE_SIZE ? (
          <Card className="flex flex-wrap items-center justify-between gap-3 py-3">
            <span className="text-body-sm text-text-secondary">
              Showing {params.offset + 1}–{Math.min(params.offset + PAGE_SIZE, sites.data.count)} of{' '}
              {sites.data.count}
            </span>
            <div className="flex items-center gap-2">
              <Button
                variant="outline"
                size="sm"
                disabled={search.page <= 1}
                onClick={() => change({ page: search.page - 1 })}
              >
                Previous
              </Button>
              <span className="text-caption text-text-secondary">
                Page {search.page} of {Math.ceil(sites.data.count / PAGE_SIZE)}
              </span>
              <Button
                variant="outline"
                size="sm"
                disabled={params.offset + PAGE_SIZE >= sites.data.count}
                onClick={() => change({ page: search.page + 1 })}
              >
                Next
              </Button>
            </div>
          </Card>
        ) : null}
      </div>

      <WorksiteForm
        key={`${formOpen}-${editing?.id ?? 'new'}`}
        open={formOpen}
        site={editing}
        projects={projectOptions.data?.items ?? []}
        error={formError}
        busy={save.isPending}
        onClose={() => setFormOpen(false)}
        onSave={(input) => save.mutate(input)}
      />
      <Dialog
        open={Boolean(deleteTarget)}
        onOpenChange={(open) => {
          if (!open) {
            setDeleteTarget(null)
            setDeleteConflict('')
          }
        }}
        title={deleteConflict ? 'Worksite has linked records' : 'Delete unused worksite?'}
        description={deleteTarget?.name}
        size="sm"
        fitContent
        footer={
          <div className="flex flex-wrap justify-end gap-2">
            <Button
              variant="outline"
              onClick={() => {
                setDeleteTarget(null)
                setDeleteConflict('')
              }}
            >
              Cancel
            </Button>
            {deleteConflict && canUpdate ? (
              <Button
                isLoading={markInactive.isPending}
                onClick={() => deleteTarget && markInactive.mutate(deleteTarget)}
              >
                Mark inactive
              </Button>
            ) : deleteConflict ? null : (
              <Button
                variant="danger"
                isLoading={remove.isPending}
                onClick={() => deleteTarget && remove.mutate(deleteTarget)}
              >
                Delete worksite
              </Button>
            )}
          </div>
        }
      >
        <p className="text-body-sm text-text-secondary">
          {deleteConflict ||
            'Deletion is allowed only when no tasks, reports, or site inventory depend on this location. Linked worksites should be marked inactive so operational history remains available.'}
        </p>
      </Dialog>
    </PageLayout>
  )
}

function WorksiteCard({
  site,
  canView,
  canUpdate,
  canDelete,
  onEdit,
  onDelete,
}: {
  site: OperationsWorksite
  canView: boolean
  canUpdate: boolean
  canDelete: boolean
  onEdit: () => void
  onDelete: () => void
}) {
  const tone =
    site.status === 'active'
      ? 'success'
      : site.status === 'inactive'
        ? 'neutral'
        : site.status === 'completed'
          ? 'info'
          : 'warning'
  return (
    <Card className="overflow-hidden p-0" elevation="sm">
      <div className="flex min-w-0 flex-wrap items-start justify-between gap-3 p-4">
        <div className="flex min-w-0 items-start gap-3">
          <span className="bg-primary-subtle text-primary rounded-control flex size-11 shrink-0 items-center justify-center">
            <MapPin className="size-5" aria-hidden="true" />
          </span>
          <div className="min-w-0">
            <div className="flex flex-wrap items-center gap-2">
              <h3 className="text-label text-text-primary font-semibold break-words">
                {site.name}
              </h3>
              <StatusChip dense label={site.status.replaceAll('_', ' ')} tone={tone} />
            </div>
            <p className="text-body-sm text-text-secondary mt-1 break-words">{site.location}</p>
            <p className="text-caption text-text-muted mt-1 break-words">
              {site.project_short_code ? `${site.project_short_code} · ` : ''}
              {site.project_name ??
                (site.project_id ? `Project #${site.project_id}` : 'Standalone worksite')}
            </p>
          </div>
        </div>
      </div>
      {site.description ? (
        <p className="text-body-sm text-text-secondary border-border-subtle border-t px-4 py-3 break-words">
          {site.description}
        </p>
      ) : null}
      <footer className="border-border-subtle flex flex-wrap items-center justify-between gap-2 border-t px-4 py-3">
        <span className="text-caption text-text-muted">Worksite #{site.id}</span>
        <div className="flex flex-wrap gap-2">
          {canView ? (
            <Link
              to="/works/worksite/$worksiteId"
              params={{ worksiteId: String(site.id) }}
              className="rounded-control border-border-strong bg-surface text-text-primary hover:bg-surface-muted focus-visible:shadow-focus-ring text-caption inline-flex min-h-9 items-center gap-2 border px-3 font-semibold"
            >
              Details <ArrowRight className="size-4" aria-hidden="true" />
            </Link>
          ) : null}
          {canUpdate ? (
            <Button size="sm" variant="outline" onClick={onEdit}>
              Edit
            </Button>
          ) : null}
          {canDelete ? (
            <Button size="sm" variant="ghost" onClick={onDelete}>
              Delete
            </Button>
          ) : null}
        </div>
      </footer>
    </Card>
  )
}

function WorksiteForm({
  open,
  site,
  projects,
  error,
  busy,
  onClose,
  onSave,
}: {
  open: boolean
  site: OperationsWorksite | null
  projects: Array<{ id: number; name: string; short_code: string }>
  error: string
  busy: boolean
  onClose: () => void
  onSave: (input: {
    project_id: number | null
    name: string
    location: string
    status: string
    description: string | null
  }) => void
}) {
  const [name, setName] = useState(site?.name ?? '')
  const [location, setLocation] = useState(site?.location ?? '')
  const [projectId, setProjectId] = useState(site?.project_id ? String(site.project_id) : '')
  const [status, setStatus] = useState(site?.status ?? 'setup')
  const [description, setDescription] = useState(site?.description ?? '')
  function submit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault()
    onSave({
      project_id: projectId ? Number(projectId) : null,
      name: name.trim(),
      location: location.trim(),
      status,
      description: description.trim() || null,
    })
  }
  return (
    <Dialog
      open={open}
      onOpenChange={(value) => !value && onClose()}
      title={site ? 'Edit worksite' : 'New worksite'}
      description="Set the location, project context, and operational status."
      size="md"
      footer={
        <div className="flex flex-wrap justify-end gap-2">
          <Button variant="outline" disabled={busy} onClick={onClose}>
            Cancel
          </Button>
          <Button type="submit" form="worksite-form" isLoading={busy}>
            {site ? 'Save changes' : 'Create worksite'}
          </Button>
        </div>
      }
    >
      <form id="worksite-form" onSubmit={submit} className="space-y-4">
        {error ? (
          <p role="alert" className="text-body-sm text-danger">
            {error}
          </p>
        ) : null}
        <FormControl id="worksite-name" label="Worksite name" required>
          <TextInput
            value={name}
            onChange={(event) => setName(event.target.value)}
            maxLength={255}
            required
          />
        </FormControl>
        <FormControl id="worksite-location" label="Address or location" required>
          <TextInput
            value={location}
            onChange={(event) => setLocation(event.target.value)}
            maxLength={255}
            required
            placeholder="City, region or site address"
          />
        </FormControl>
        <FormControl id="worksite-project" label="Project">
          <DropdownSelect
            value={projectId}
            options={[
              { value: '', label: 'Standalone worksite' },
              ...projects.map((project) => ({
                value: String(project.id),
                label: `${project.short_code} · ${project.name}`,
              })),
            ]}
            onChange={setProjectId}
            searchable
          />
        </FormControl>
        <FormControl id="worksite-status" label="Status">
          <DropdownSelect
            value={status}
            options={statuses.filter(({ value }) => value !== 'all')}
            onChange={setStatus}
          />
        </FormControl>
        <FormControl id="worksite-description" label="Site notes">
          <TextArea
            value={description}
            onChange={(event) => setDescription(event.target.value)}
            rows={3}
            maxLength={2000}
            placeholder="Access notes, scope, or safety context"
          />
        </FormControl>
      </form>
    </Dialog>
  )
}

export function WorksiteDetailPage() {
  const params = useParams({ strict: false }) as { worksiteId?: string }
  const siteId = Number(params.worksiteId)
  const sessionQuery = useQuery(authSessionQueryOptions())
  const session = sessionQuery.data
  const detail = useQuery({
    ...operationsRegisterQueries.worksite(
      session?.user.id ?? 0,
      session?.employee.employee_id ?? '',
      siteId,
    ),
    enabled: Boolean(
      session &&
      Number.isSafeInteger(siteId) &&
      siteId > 0 &&
      hasPermission(session.permissions, 'worksites', 'view'),
    ),
  })
  const canViewTasks = Boolean(session && hasPermission(session.permissions, 'tasks', 'list'))
  const canViewReports = Boolean(
    session && hasPermission(session.permissions, 'engineering_site_reports', 'list'),
  )
  return (
    <PageLayout
      title={detail.data?.name ?? 'Worksite details'}
      subtitle="Location context and related operational records."
      backLink={
        <Link
          to="/works/worksite"
          search={{ search: '', status: 'all', projectId: null, page: 1 }}
          className={pageBackLinkClassName}
        >
          <PageBackLinkContent>Worksites</PageBackLinkContent>
        </Link>
      }
    >
      {detail.isPending ? (
        <Skeleton variant="card" className="h-64" />
      ) : detail.isError ? (
        <ErrorState
          title="Worksite details unavailable"
          error={detail.error}
          action={
            <Button variant="outline" onClick={() => void detail.refetch()}>
              Try again
            </Button>
          }
        />
      ) : detail.data ? (
        <div className="space-y-4">
          <Card>
            <div className="flex flex-wrap items-start justify-between gap-3">
              <div>
                <p className="text-overline text-primary font-semibold">
                  Worksite #{detail.data.id}
                </p>
                <h2 className="text-h2 text-text-primary mt-1 font-semibold">{detail.data.name}</h2>
                <p className="text-body text-text-secondary mt-2">{detail.data.location}</p>
              </div>
              <StatusChip
                label={detail.data.status.replaceAll('_', ' ')}
                tone={detail.data.status === 'active' ? 'success' : 'neutral'}
              />
            </div>
            <div className="tablet:grid-cols-2 mt-5 grid gap-3">
              <Fact
                label="Project"
                value={
                  detail.data.project_name ??
                  (detail.data.project_id ? `Project #${detail.data.project_id}` : 'Standalone')
                }
              />
              <Fact
                label="Coordinates"
                value={
                  detail.data.latitude && detail.data.longitude
                    ? `${detail.data.latitude}, ${detail.data.longitude}`
                    : 'Not recorded'
                }
              />
              <Fact label="Site notes" value={detail.data.description || 'No additional notes'} />
            </div>
          </Card>
          <div className="tablet:grid-cols-2 grid gap-3">
            {canViewTasks ? (
              <Card>
                <h3 className="text-label text-text-primary font-semibold">Tasks at this site</h3>
                <p className="text-body-sm text-text-secondary mt-1">
                  Review delivery work linked to this location.
                </p>
                <Link
                  to="/works/tasks"
                  search={{
                    search: '',
                    status: 'all',
                    priority: '',
                    projectId: detail.data.project_id,
                    worksiteId: detail.data.id,
                    page: 1,
                  }}
                  className="text-body-sm text-primary mt-4 inline-flex items-center gap-2 font-semibold"
                >
                  Open site tasks <ArrowRight className="size-4" />
                </Link>
              </Card>
            ) : null}
            {canViewReports ? (
              <Card>
                <h3 className="text-label text-text-primary font-semibold">Engineering reports</h3>
                <p className="text-body-sm text-text-secondary mt-1">
                  See submitted reports and the site’s reporting history.
                </p>
                <Link
                  to="/works/engineering-site-reports"
                  search={{
                    status: 'all',
                    employeeId: null,
                    projectId: detail.data.project_id,
                    worksiteId: detail.data.id,
                    dateFrom: '',
                    dateTo: '',
                    page: 1,
                  }}
                  className="text-body-sm text-primary mt-4 inline-flex items-center gap-2 font-semibold"
                >
                  Open site reports <ArrowRight className="size-4" />
                </Link>
              </Card>
            ) : null}
          </div>
        </div>
      ) : null}
    </PageLayout>
  )
}

function Fact({ label, value }: { label: string; value: string }) {
  return (
    <div className="bg-surface-muted rounded-control min-w-0 p-3">
      <p className="text-caption text-text-secondary">{label}</p>
      <p className="text-body-sm text-text-primary mt-1 break-words">{value}</p>
    </div>
  )
}
