import { useRef, useState, type FormEvent, type ReactNode } from 'react'
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query'
import { useNavigate, useParams, useSearch } from '@tanstack/react-router'
import {
  Archive,
  ArrowLeft,
  CalendarDays,
  Check,
  ClipboardList,
  CircleAlert,
  Download,
  FileText,
  FolderKanban,
  HardHat,
  MapPin,
  Pencil,
  Plus,
  RotateCcw,
  Trash2,
  Users,
  Video,
} from 'lucide-react'

import { authSessionQueryOptions, hasPermission } from '@/shared/auth/session'
import { Button } from '@/shared/ui/button'
import { Card } from '@/shared/ui/card'
import { Dialog } from '@/shared/ui/dialog'
import { DropdownSelect } from '@/shared/ui/dropdown-select'
import { EmptyState, ErrorState, SectionErrorState, Skeleton } from '@/shared/ui/feedback-states'
import { FormControl, TextArea, TextInput } from '@/shared/ui/form-control'
import { FormSection } from '@/shared/ui/form-section'
import { PageLayout } from '@/shared/ui/page-layout'
import { ProgressBar } from '@/shared/ui/progress-bar'
import { StatusChip } from '@/shared/ui/status-chip'
import { useToast } from '@/shared/feedback/use-toast'
import {
  projectQueryKeys,
  projectsApi,
  type ProjectAssociateDto,
  type ProjectAssociateOptionDto,
  type ProjectDto,
  type ProjectEmployeeOptionDto,
  type ProjectMeetingDto,
  type ProjectMilestoneDto,
  type ProjectTaskDto,
  type ProjectWorksiteDto,
  type ProjectWriteInput,
} from '../projects.api'
import { projectQueries } from '../projects.queries'
import { PROJECT_TABS, type ProjectDetailSearch, type ProjectTab } from '../projects.search'
import { ProjectFormDialog } from './project-form-dialog'

const tabLabels: Record<ProjectTab, string> = {
  overview: 'Overview',
  members: 'Members',
  worksite: 'Work site',
  files: 'Files',
  milestones: 'Milestones',
  tasks: 'Tasks',
  associates: 'Associates',
  meetings: 'Meetings',
}
const tabIcons: Record<ProjectTab, ReactNode> = {
  overview: <FolderKanban className="size-4" />,
  members: <Users className="size-4" />,
  worksite: <HardHat className="size-4" />,
  files: <FileText className="size-4" />,
  milestones: <Check className="size-4" />,
  tasks: <ClipboardList className="size-4" />,
  associates: <Users className="size-4" />,
  meetings: <Video className="size-4" />,
}

function canViewTab(tab: ProjectTab, permissions: Record<string, string[]>): boolean {
  switch (tab) {
    case 'overview':
    case 'files':
    case 'associates':
      return hasPermission(permissions, 'projects', 'view')
    case 'members':
      return (
        hasPermission(permissions, 'projects', 'list') ||
        hasPermission(permissions, 'projects', 'view')
      )
    case 'worksite':
      return ['list', 'view'].some((action) => hasPermission(permissions, 'worksites', action))
    case 'milestones':
      return ['list', 'view'].some((action) => hasPermission(permissions, 'milestones', action))
    case 'tasks':
      return ['list', 'view', 'list_own'].some((action) =>
        hasPermission(permissions, 'tasks', action),
      )
    case 'meetings':
      return ['list', 'view'].some((action) => hasPermission(permissions, 'meetings', action))
  }
}

function canCreateTab(tab: ProjectTab, permissions: Record<string, string[]>): boolean {
  if (tab === 'overview') return false
  if (tab === 'members' || tab === 'files' || tab === 'associates')
    return hasPermission(permissions, 'projects', 'update')
  if (tab === 'worksite') return hasPermission(permissions, 'worksites', 'create')
  if (tab === 'milestones') return hasPermission(permissions, 'milestones', 'create')
  if (tab === 'tasks') return hasPermission(permissions, 'tasks', 'create')
  return hasPermission(permissions, 'meetings', 'create')
}

function labelStatus(value: string) {
  return value.replaceAll('_', ' ').replace(/^./, (letter) => letter.toUpperCase())
}
function money(value: string | null) {
  if (value === null || value === '') return 'Not set'
  const amount = Number(value)
  return Number.isFinite(amount)
    ? new Intl.NumberFormat('en-NG', {
        style: 'currency',
        currency: 'NGN',
        maximumFractionDigits: 0,
      }).format(amount)
    : 'Not available'
}
function shortDate(value: string | null) {
  if (!value) return 'Not set'
  const date = new Date(`${value.slice(0, 10)}T00:00:00`)
  return Number.isNaN(date.getTime())
    ? value
    : new Intl.DateTimeFormat(undefined, {
        day: 'numeric',
        month: 'short',
        year: 'numeric',
      }).format(date)
}
function statusTone(value: string): 'neutral' | 'info' | 'success' | 'warning' | 'danger' {
  if (['completed', 'approved', 'active'].includes(value)) return 'success'
  if (['in_progress', 'scheduled'].includes(value)) return 'info'
  if (['on_hold', 'pending'].includes(value)) return 'warning'
  if (['cancelled', 'rejected'].includes(value)) return 'danger'
  return 'neutral'
}

type EntryKind = 'worksite' | 'milestone' | 'task' | 'meeting' | 'associate'
type EntryDraft = { kind: EntryKind; recordId?: number; values: Record<string, string> }
const defaultDraft: Record<EntryKind, Record<string, string>> = {
  worksite: { name: '', location: '', status: 'active', description: '' },
  milestone: {
    name: '',
    description: '',
    status: 'pending',
    priority: 'medium',
    progress: '0',
    budget: '',
    start_date: '',
    end_date: '',
  },
  task: {
    name: '',
    description: '',
    status: 'pending',
    priority: 'medium',
    due_date: '',
    estimated_hours: '',
    milestone_id: '',
  },
  meeting: {
    title: '',
    agenda: '',
    meeting_date: '',
    meeting_time: '',
    duration_minutes: '60',
    location_type: 'physical',
    location: '',
    notes: '',
  },
  associate: { partner_id: '', project_role: '' },
}

export function ProjectDetailPage() {
  const params = useParams({ from: '/_protected/works/projects/$projectId' })
  const projectId = Number(params.projectId)
  const search = useSearch({ from: '/_protected/works/projects/$projectId' }) as ProjectDetailSearch
  const navigate = useNavigate()
  const queryClient = useQueryClient()
  const { showToast } = useToast()
  const sessionQuery = useQuery(authSessionQueryOptions())
  const session = sessionQuery.data
  const permissions = session?.permissions ?? {}
  const detail = useQuery({
    ...projectQueries.detail(session?.user.id ?? 0, String(session?.employee.id ?? ''), projectId),
    enabled: Boolean(session) && Number.isSafeInteger(projectId) && projectId > 0,
  })
  const activeTab = search.tab
  const idScope = [session?.user.id ?? 0, String(session?.employee.id ?? '')] as const
  const employees = useQuery({
    ...projectQueries.employees(...idScope, projectId),
    enabled: Boolean(session) && activeTab === 'members' && projectId > 0,
  })
  const employeeOptions = useQuery({
    queryKey: projectQueryKeys.tab(...idScope, projectId, 'member-options'),
    queryFn: ({ signal }) => projectsApi.employeeOptions(projectId, '', signal),
    staleTime: 60_000,
    enabled: Boolean(session) && activeTab === 'members' && projectId > 0,
  })
  const worksites = useQuery({
    ...projectQueries.worksites(...idScope, projectId),
    enabled: Boolean(session) && activeTab === 'worksite' && projectId > 0,
  })
  const files = useQuery({
    ...projectQueries.files(...idScope, projectId),
    enabled: Boolean(session) && activeTab === 'files' && projectId > 0,
  })
  const milestones = useQuery({
    ...projectQueries.milestones(...idScope, projectId),
    enabled:
      Boolean(session) && (activeTab === 'milestones' || activeTab === 'tasks') && projectId > 0,
  })
  const tasks = useQuery({
    ...projectQueries.tasks(...idScope, projectId),
    enabled: Boolean(session) && activeTab === 'tasks' && projectId > 0,
  })
  const associates = useQuery({
    ...projectQueries.associates(...idScope, projectId),
    enabled: Boolean(session) && activeTab === 'associates' && projectId > 0,
  })
  const associateOptions = useQuery({
    queryKey: projectQueryKeys.tab(...idScope, projectId, 'associate-options'),
    queryFn: ({ signal }) => projectsApi.associateOptions(projectId, '', signal),
    staleTime: 60_000,
    enabled: Boolean(session) && activeTab === 'associates' && projectId > 0,
  })
  const meetings = useQuery({
    ...projectQueries.meetings(...idScope, projectId),
    enabled: Boolean(session) && activeTab === 'meetings' && projectId > 0,
  })
  const timelines = useQuery({
    queryKey: projectQueryKeys.tab(...idScope, projectId, 'timelines'),
    queryFn: ({ signal }) => projectsApi.timelines(projectId, signal),
    enabled: Boolean(session) && activeTab === 'overview' && projectId > 0,
    staleTime: 60_000,
  })
  const [editOpen, setEditOpen] = useState(false)
  const [deleteProjectOpen, setDeleteProjectOpen] = useState(false)
  const [entry, setEntry] = useState<EntryDraft | null>(null)
  const [deleteFileId, setDeleteFileId] = useState<number | null>(null)
  const [cancelMeetingTarget, setCancelMeetingTarget] = useState<ProjectMeetingDto | null>(null)
  const [deleteEntry, setDeleteEntry] = useState<{
    kind: 'worksite' | 'milestone' | 'task'
    id: number
    name: string
  } | null>(null)
  const [memberSelectionDraft, setMemberSelectionDraft] = useState<{
    projectId: number
    ids: number[]
  } | null>(null)
  const assignedMemberIds = (employees.data?.items ?? []).map((employee) => Number(employee.id))
  const memberSelection =
    memberSelectionDraft?.projectId === projectId ? memberSelectionDraft.ids : assignedMemberIds
  const fileInputRef = useRef<HTMLInputElement>(null)

  const invalidate = async (tab?: string) => {
    await Promise.all([
      queryClient.invalidateQueries({ queryKey: projectQueryKeys.detail(...idScope, projectId) }),
      ...(tab
        ? [
            queryClient.invalidateQueries({
              queryKey: projectQueryKeys.tab(...idScope, projectId, tab),
            }),
          ]
        : []),
      queryClient.invalidateQueries({ queryKey: projectQueryKeys.all }),
      queryClient.invalidateQueries({ queryKey: ['operations', 'dashboard', 'overview'] }),
    ])
  }
  const mutationError = (title: string) =>
    showToast({
      title,
      description: 'Please try again. If the problem continues, refresh this section.',
      tone: 'danger',
    })
  const mutationSuccess = (title: string) => showToast({ title, tone: 'success' })

  const updateProject = useMutation({
    mutationFn: (input: ProjectWriteInput) => projectsApi.update(projectId, input),
    onSuccess: async () => {
      await invalidate()
      setEditOpen(false)
      mutationSuccess('Project updated')
    },
    onError: () => mutationError('Project could not be updated'),
  })
  const archive = useMutation({
    mutationFn: () =>
      detail.data?.is_archived ? projectsApi.restore(projectId) : projectsApi.archive(projectId),
    onSuccess: async () => {
      await invalidate()
      mutationSuccess(detail.data?.is_archived ? 'Project restored' : 'Project archived')
    },
    onError: () => mutationError('Project status could not be changed'),
  })
  const removeProject = useMutation({
    mutationFn: () => projectsApi.remove(projectId),
    onSuccess: async () => {
      await navigate({ to: '/works/projects' })
      await invalidate()
      mutationSuccess('Project permanently deleted')
    },
    onError: () => mutationError('Project could not be deleted'),
  })
  const updateMembers = useMutation({
    mutationFn: (employeeIds: number[]) => projectsApi.updateEmployees(projectId, employeeIds),
    onSuccess: async () => {
      setMemberSelectionDraft(null)
      await invalidate('members')
      mutationSuccess('Project team updated')
    },
    onError: () => mutationError('Project team could not be updated'),
  })
  const uploadFile = useMutation({
    mutationFn: (file: File) => projectsApi.uploadFile(projectId, file),
    onSuccess: async () => {
      await invalidate('files')
      mutationSuccess('File uploaded')
    },
    onError: () => mutationError('File could not be uploaded'),
  })
  const deleteFile = useMutation({
    mutationFn: (fileId: number) => projectsApi.removeFile(projectId, fileId),
    onSuccess: async () => {
      await invalidate('files')
      setDeleteFileId(null)
      mutationSuccess('File deleted')
    },
    onError: () => mutationError('File could not be deleted'),
  })
  const removeChild = useMutation({
    mutationFn: async ({ kind, id }: { kind: 'worksite' | 'milestone' | 'task'; id: number }) => {
      if (kind === 'worksite') return projectsApi.removeWorksite(id)
      if (kind === 'milestone') return projectsApi.removeMilestone(id)
      return projectsApi.removeTask(id)
    },
    onSuccess: async (_, variables) => {
      await invalidate(
        variables.kind === 'worksite'
          ? 'worksite'
          : variables.kind === 'milestone'
            ? 'milestones'
            : 'tasks',
      )
      setDeleteEntry(null)
      mutationSuccess('Record deleted')
    },
    onError: () => mutationError('Record could not be deleted'),
  })
  const cancelMeeting = useMutation({
    mutationFn: (meetingId: number) => projectsApi.cancelMeeting(meetingId),
    onSuccess: async () => {
      await invalidate('meetings')
      setCancelMeetingTarget(null)
      mutationSuccess('Meeting cancelled')
    },
    onError: () => mutationError('Meeting could not be cancelled'),
  })

  async function saveEntry(values: Record<string, string>) {
    if (!entry) return
    if (entry.kind === 'worksite') {
      const input = {
        project_id: projectId,
        name: values.name.trim(),
        location: values.location.trim(),
        status: values.status,
        description: values.description.trim() || null,
      }
      if (entry.recordId) await projectsApi.updateWorksite(entry.recordId, input)
      else await projectsApi.createWorksite(input)
      await invalidate('worksite')
    } else if (entry.kind === 'milestone') {
      const input = {
        project_id: projectId,
        name: values.name.trim(),
        description: values.description.trim() || null,
        status: values.status,
        priority: values.priority,
        progress: Number(values.progress || 0),
        budget: values.budget ? String(values.budget) : null,
        start_date: values.start_date || null,
        end_date: values.end_date || null,
      }
      if (entry.recordId) await projectsApi.updateMilestone(entry.recordId, input)
      else await projectsApi.createMilestone(input)
      await invalidate('milestones')
    } else if (entry.kind === 'task') {
      const input = {
        project_id: projectId,
        milestone_id: values.milestone_id ? Number(values.milestone_id) : null,
        name: values.name.trim(),
        description: values.description.trim() || null,
        status: values.status,
        priority: values.priority,
        due_date: values.due_date || null,
        estimated_hours: values.estimated_hours || null,
      }
      if (entry.recordId) await projectsApi.updateTask(entry.recordId, input)
      else await projectsApi.createTask(input)
      await invalidate('tasks')
    } else if (entry.kind === 'meeting') {
      const input = {
        project_id: projectId,
        title: values.title.trim(),
        agenda: values.agenda.trim(),
        meeting_date: values.meeting_date,
        meeting_time: values.meeting_time,
        duration_minutes: Number(values.duration_minutes || 60),
        status: values.status || 'scheduled',
        location_type: values.location_type,
        location: values.location.trim(),
        notes: values.notes.trim(),
      }
      if (entry.recordId) await projectsApi.updateMeeting(entry.recordId, input)
      else await projectsApi.createMeeting(input)
      await invalidate('meetings')
    } else {
      await projectsApi.addAssociate(
        projectId,
        Number(values.partner_id),
        values.project_role.trim(),
      )
      await invalidate('associates')
    }
    setEntry(null)
    mutationSuccess(entry.recordId ? 'Changes saved' : `${tabLabels[activeTab]} record added`)
  }
  const entryMutation = useMutation({
    mutationFn: saveEntry,
    onError: () => mutationError('Record could not be saved'),
  })
  const entryBusy = entryMutation.isPending
  const tabs = PROJECT_TABS.filter((tab) => canViewTab(tab, permissions))
  const project = detail.data
  const canToggleArchive = project
    ? hasPermission(permissions, 'projects', project.is_archived ? 'restore' : 'archive')
    : false

  return (
    <PageLayout
      title={project?.name ?? 'Project'}
      subtitle={
        project
          ? `${project.short_code} · ${project.category}${project.branch_name ? ` · ${project.branch_name}` : ''}`
          : 'Project workspace'
      }
      actionsInline
      backLink={
        <Button
          variant="outline"
          size="icon"
          aria-label="Back to projects"
          onClick={() => void navigate({ to: '/works/projects' })}
        >
          <ArrowLeft className="size-4" />
        </Button>
      }
      actions={
        project ? (
          <>
            {hasPermission(permissions, 'projects', 'update') && !project.is_archived ? (
              <Button
                variant="outline"
                size="sm"
                aria-label={`Edit ${project.name}`}
                leadingIcon={<Pencil className="size-4" aria-hidden="true" />}
                className="max-[699px]:size-10 max-[699px]:gap-0 max-[699px]:px-0"
                onClick={() => setEditOpen(true)}
              >
                <span className="max-[699px]:sr-only">Edit</span>
              </Button>
            ) : null}
            {canToggleArchive ? (
              <Button
                variant="outline"
                size="sm"
                aria-label={`${project.is_archived ? 'Restore' : 'Archive'} ${project.name}`}
                leadingIcon={
                  project.is_archived ? (
                    <RotateCcw className="size-4" aria-hidden="true" />
                  ) : (
                    <Archive className="size-4" aria-hidden="true" />
                  )
                }
                className="max-[699px]:size-10 max-[699px]:gap-0 max-[699px]:px-0"
                onClick={() => archive.mutate()}
                isLoading={archive.isPending}
              >
                <span className="max-[699px]:sr-only">
                  {project.is_archived ? 'Restore' : 'Archive'}
                </span>
              </Button>
            ) : null}
            {hasPermission(permissions, 'projects', 'delete') ? (
              <Button
                variant="danger"
                size="sm"
                aria-label={`Delete ${project.name}`}
                leadingIcon={<Trash2 className="size-4" aria-hidden="true" />}
                className="max-[699px]:size-10 max-[699px]:gap-0 max-[699px]:px-0"
                onClick={() => setDeleteProjectOpen(true)}
              >
                <span className="max-[699px]:sr-only">Delete</span>
              </Button>
            ) : null}
          </>
        ) : undefined
      }
    >
      {detail.isPending ? (
        <div className="grid gap-4">
          <Skeleton className="h-28" />
          <Skeleton className="h-72" />
        </div>
      ) : detail.isError || !project ? (
        <ErrorState
          title="Project could not load"
          description="It may have been removed or is outside your branch access."
          error={detail.error}
          action={
            <Button variant="outline" onClick={() => void detail.refetch()}>
              Try again
            </Button>
          }
        />
      ) : (
        <>
          {project.is_archived ? (
            <div className="mb-4">
              <StatusChip label="Archived project" tone="neutral" />{' '}
              <span className="text-caption text-text-secondary ml-2">
                This project is preserved but excluded from active Operations metrics.
              </span>
            </div>
          ) : null}
          <Card className="mb-4 overflow-hidden p-0">
            <nav
              aria-label="Project sections"
              className="bg-surface-muted desktop:grid-cols-4 tablet:grid-cols-3 grid min-w-0 grid-cols-2 gap-1.5 p-2"
            >
              {tabs.map((tab) => (
                <button
                  key={tab}
                  type="button"
                  onClick={() =>
                    void navigate({
                      to: '/works/projects/$projectId',
                      params: { projectId: String(projectId) },
                      search: (previous: ProjectDetailSearch) => ({ ...previous, tab }),
                    })
                  }
                  aria-current={activeTab === tab ? 'page' : undefined}
                  className={`rounded-control focus-visible:shadow-focus-ring flex min-h-10 min-w-0 items-center gap-2 px-2 py-2 text-left font-semibold transition-colors focus-visible:outline-none sm:px-3 ${activeTab === tab ? 'bg-surface text-primary shadow-elevation-sm' : 'text-text-secondary hover:bg-surface/70'}`}
                >
                  <span className="text-primary rounded-control bg-primary-subtle flex size-7 shrink-0 items-center justify-center">
                    {tabIcons[tab]}
                  </span>
                  <span className="text-caption min-w-0 flex-1 leading-snug break-words">
                    {tabLabels[tab]}
                  </span>
                </button>
              ))}
            </nav>
          </Card>
          {!canViewTab(activeTab, permissions) ? (
            <EmptyState
              title="You do not have access to this section"
              description="Ask an administrator to grant the relevant project permission."
            />
          ) : (
            <>
              {activeTab === 'overview' ? (
                <OverviewPanel
                  project={project}
                  timelines={timelines.data?.items ?? []}
                  isLoading={timelines.isPending}
                  isError={timelines.isError}
                  onRetry={() => void timelines.refetch()}
                />
              ) : null}
              {activeTab === 'members' ? (
                <MembersPanel
                  options={employeeOptions.data ?? []}
                  isLoading={employeeOptions.isPending || employees.isPending}
                  isError={employeeOptions.isError || employees.isError}
                  selected={memberSelection}
                  setSelected={(ids) => setMemberSelectionDraft({ projectId, ids })}
                  onSave={() => updateMembers.mutate(memberSelection)}
                  saving={updateMembers.isPending}
                  canEdit={hasPermission(permissions, 'projects', 'update')}
                  retry={() => {
                    void employeeOptions.refetch()
                    void employees.refetch()
                  }}
                />
              ) : null}
              {activeTab === 'worksite' ? (
                <ListPanel
                  title="Project worksites"
                  description="Field locations linked to this project."
                  isLoading={worksites.isPending}
                  isError={worksites.isError}
                  onRetry={() => void worksites.refetch()}
                  onAdd={() => setEntry({ kind: 'worksite', values: { ...defaultDraft.worksite } })}
                  canAdd={canCreateTab(activeTab, permissions)}
                  addLabel="Add worksite"
                  empty="No worksite has been linked to this project yet."
                >
                  {(worksites.data?.items ?? []).map((item) => (
                    <WorksiteCard
                      key={item.id}
                      item={item}
                      canEdit={hasPermission(permissions, 'worksites', 'update')}
                      canDelete={hasPermission(permissions, 'worksites', 'delete')}
                      onEdit={() =>
                        setEntry({
                          kind: 'worksite',
                          recordId: item.id,
                          values: worksiteDraft(item),
                        })
                      }
                      onDelete={() =>
                        setDeleteEntry({ kind: 'worksite', id: item.id, name: item.name })
                      }
                    />
                  ))}
                </ListPanel>
              ) : null}
              {activeTab === 'files' ? (
                <ListPanel
                  title="Project files"
                  description="Files are private and are only available to authorized project users."
                  isLoading={files.isPending}
                  isError={files.isError}
                  onRetry={() => void files.refetch()}
                  onAdd={() => fileInputRef.current?.click()}
                  canAdd={hasPermission(permissions, 'projects', 'update')}
                  addLabel="Upload file"
                  empty="No files have been uploaded to this project."
                >
                  {(files.data ?? []).map((file) => (
                    <Card
                      key={file.id}
                      className="flex min-w-0 flex-wrap items-center justify-between gap-3"
                    >
                      <span className="flex min-w-0 items-center gap-3">
                        <span className="bg-primary-subtle text-primary rounded-control flex size-10 shrink-0 items-center justify-center">
                          <FileText className="size-5" />
                        </span>
                        <span className="min-w-0">
                          <span className="text-label block font-semibold break-words">
                            {file.original_filename}
                          </span>
                          <span className="text-caption text-text-secondary block">
                            {formatBytes(file.size)} · {file.uploaded_by_name ?? 'Team member'} ·{' '}
                            {shortDate(file.created_at)}
                          </span>
                        </span>
                      </span>
                      <span className="flex gap-2">
                        <a
                          href={file.download_url}
                          className="border-border-strong bg-surface text-text-primary hover:bg-surface-muted rounded-control text-caption inline-flex min-h-9 items-center justify-center gap-2 border px-3 font-semibold"
                        >
                          <Download className="size-4" />
                          Download
                        </a>
                        {hasPermission(permissions, 'projects', 'update') ? (
                          <Button
                            variant="danger"
                            size="sm"
                            aria-label={`Delete ${file.original_filename}`}
                            onClick={() => setDeleteFileId(file.id)}
                          >
                            <Trash2 className="size-4" />
                          </Button>
                        ) : null}
                      </span>
                    </Card>
                  ))}
                </ListPanel>
              ) : null}
              {activeTab === 'milestones' ? (
                <ListPanel
                  title="Milestones"
                  description="Track key phases, dates, and allocated amounts."
                  isLoading={milestones.isPending}
                  isError={milestones.isError}
                  onRetry={() => void milestones.refetch()}
                  onAdd={() =>
                    setEntry({ kind: 'milestone', values: { ...defaultDraft.milestone } })
                  }
                  canAdd={canCreateTab(activeTab, permissions)}
                  addLabel="Add milestone"
                  empty="No milestones have been added yet."
                >
                  {(milestones.data?.items ?? []).map((item) => (
                    <MilestoneCard
                      key={item.id}
                      item={item}
                      canEdit={hasPermission(permissions, 'milestones', 'update')}
                      canDelete={hasPermission(permissions, 'milestones', 'delete')}
                      onEdit={() =>
                        setEntry({
                          kind: 'milestone',
                          recordId: item.id,
                          values: milestoneDraft(item),
                        })
                      }
                      onDelete={() =>
                        setDeleteEntry({ kind: 'milestone', id: item.id, name: item.name })
                      }
                    />
                  ))}
                </ListPanel>
              ) : null}
              {activeTab === 'tasks' ? (
                <ListPanel
                  title="Project tasks"
                  description="Work items and delivery tasks assigned to this project."
                  isLoading={tasks.isPending || milestones.isPending}
                  isError={tasks.isError || milestones.isError}
                  onRetry={() => {
                    void tasks.refetch()
                    void milestones.refetch()
                  }}
                  onAdd={() => setEntry({ kind: 'task', values: { ...defaultDraft.task } })}
                  canAdd={canCreateTab(activeTab, permissions)}
                  addLabel="Add task"
                  empty="No tasks have been added yet."
                >
                  {(tasks.data?.items ?? []).map((item) => (
                    <TaskCard
                      key={item.id}
                      item={item}
                      milestone={
                        milestones.data?.items.find(
                          (milestone) => milestone.id === item.milestone_id,
                        )?.name
                      }
                      canEdit={hasPermission(permissions, 'tasks', 'update')}
                      canDelete={hasPermission(permissions, 'tasks', 'delete')}
                      onEdit={() =>
                        setEntry({ kind: 'task', recordId: item.id, values: taskDraft(item) })
                      }
                      onDelete={() =>
                        setDeleteEntry({ kind: 'task', id: item.id, name: item.name })
                      }
                    />
                  ))}
                </ListPanel>
              ) : null}
              {activeTab === 'associates' ? (
                <ListPanel
                  title="Project associates"
                  description="Partner organizations connected to this project."
                  isLoading={associates.isPending}
                  isError={associates.isError}
                  onRetry={() => void associates.refetch()}
                  onAdd={() =>
                    setEntry({ kind: 'associate', values: { ...defaultDraft.associate } })
                  }
                  canAdd={canCreateTab(activeTab, permissions)}
                  addLabel="Add associate"
                  empty="No partner associates are linked to this project."
                >
                  {(associates.data ?? []).map((item) => (
                    <AssociateCard
                      key={item.id}
                      item={item}
                      canDelete={hasPermission(permissions, 'projects', 'update')}
                      onDelete={() =>
                        projectsApi
                          .removeAssociate(projectId, item.partner_id)
                          .then(() => invalidate('associates'))
                          .then(() => mutationSuccess('Associate removed'))
                          .catch(() => mutationError('Associate could not be removed'))
                      }
                    />
                  ))}
                </ListPanel>
              ) : null}
              {activeTab === 'meetings' ? (
                <ListPanel
                  title="Project meetings"
                  description="Meetings linked to this project. General company meetings remain available separately."
                  isLoading={meetings.isPending}
                  isError={meetings.isError}
                  onRetry={() => void meetings.refetch()}
                  onAdd={() => setEntry({ kind: 'meeting', values: { ...defaultDraft.meeting } })}
                  canAdd={canCreateTab(activeTab, permissions)}
                  addLabel="Add meeting"
                  empty="No meetings are linked to this project yet."
                >
                  {(meetings.data?.items ?? []).map((item) => (
                    <MeetingCard
                      key={item.id}
                      item={item}
                      canEdit={hasPermission(permissions, 'meetings', 'update')}
                      canCancel={hasPermission(permissions, 'meetings', 'delete')}
                      onEdit={() =>
                        setEntry({
                          kind: 'meeting',
                          recordId: item.id,
                          values: {
                            title: item.title,
                            agenda: item.agenda,
                            meeting_date: item.meeting_date,
                            meeting_time: item.meeting_time.slice(0, 5),
                            duration_minutes: String(item.duration_minutes),
                            status: item.status,
                            location_type: item.location_type,
                            location: item.location ?? '',
                            notes: item.notes ?? '',
                          },
                        })
                      }
                      onCancel={() => setCancelMeetingTarget(item)}
                    />
                  ))}
                </ListPanel>
              ) : null}
            </>
          )}
        </>
      )}
      {editOpen && project ? (
        <ProjectFormDialog
          open
          project={project}
          onOpenChange={setEditOpen}
          onSave={(input) => updateProject.mutateAsync(input).then(() => undefined)}
          saving={updateProject.isPending}
        />
      ) : null}
      <EntryDialog
        key={entry ? `${entry.kind}:${entry.recordId ?? 'new'}` : 'closed'}
        open={Boolean(entry)}
        entry={entry}
        milestones={milestones.data?.items ?? []}
        associates={associateOptions.data ?? []}
        saving={entryBusy}
        onClose={() => setEntry(null)}
        onSave={(values) => entryMutation.mutateAsync(values).then(() => undefined)}
      />
      <input
        ref={fileInputRef}
        type="file"
        className="sr-only"
        aria-label="Upload project file"
        onChange={(event) => {
          const file = event.currentTarget.files?.[0]
          if (file) uploadFile.mutate(file)
          event.currentTarget.value = ''
        }}
      />
      <Dialog
        open={deleteProjectOpen}
        onOpenChange={setDeleteProjectOpen}
        title="Permanently delete project?"
        description="This action cannot be undone. Archive instead if the project history may be needed later."
        compactOnMobile
        fitContent
        bodyClassName="bg-background"
        footer={
          <>
            <Button variant="outline" onClick={() => setDeleteProjectOpen(false)}>
              Cancel
            </Button>
            <Button
              variant="danger"
              onClick={() => removeProject.mutate()}
              isLoading={removeProject.isPending}
            >
              <Trash2 className="size-4" />
              Delete permanently
            </Button>
          </>
        }
      >
        <FormSection className="flex items-start gap-3">
          <span className="bg-danger-subtle text-danger rounded-control flex size-9 shrink-0 items-center justify-center">
            <CircleAlert className="size-4" aria-hidden="true" />
          </span>
          <div className="min-w-0">
            <p className="text-label font-semibold">{project?.name ?? 'This project'}</p>
            <p className="text-caption text-text-secondary mt-1">
              The project and its linked records may be permanently removed.
            </p>
          </div>
        </FormSection>
      </Dialog>
      <Dialog
        open={deleteFileId !== null}
        onOpenChange={(open) => {
          if (!open) setDeleteFileId(null)
        }}
        title="Delete project file?"
        description="The private file will be removed from this project."
        compactOnMobile
        fitContent
        bodyClassName="bg-background"
        footer={
          <>
            <Button variant="outline" onClick={() => setDeleteFileId(null)}>
              Cancel
            </Button>
            <Button
              variant="danger"
              onClick={() => deleteFileId !== null && deleteFile.mutate(deleteFileId)}
              isLoading={deleteFile.isPending}
            >
              Delete file
            </Button>
          </>
        }
      >
        <FormSection className="space-y-1">
          <p className="text-label font-semibold">
            {(files.data ?? []).find((file) => file.id === deleteFileId)?.original_filename ??
              'Selected project file'}
          </p>
          <p className="text-caption text-text-secondary">This cannot be undone.</p>
        </FormSection>
      </Dialog>
      <Dialog
        open={deleteEntry !== null}
        onOpenChange={(open) => {
          if (!open) setDeleteEntry(null)
        }}
        title="Delete this record?"
        description="This permanently removes the selected project record."
        compactOnMobile
        fitContent
        bodyClassName="bg-background"
        footer={
          <>
            <Button variant="outline" onClick={() => setDeleteEntry(null)}>
              Cancel
            </Button>
            <Button
              variant="danger"
              onClick={() => deleteEntry && removeChild.mutate(deleteEntry)}
              isLoading={removeChild.isPending}
            >
              Delete record
            </Button>
          </>
        }
      >
        <FormSection>
          <p className="text-label font-semibold">{deleteEntry?.name}</p>
        </FormSection>
      </Dialog>
      <Dialog
        open={cancelMeetingTarget !== null}
        onOpenChange={(open) => {
          if (!open) setCancelMeetingTarget(null)
        }}
        title="Cancel this meeting?"
        description="The meeting will remain in the project history with a cancelled status."
        compactOnMobile
        fitContent
        bodyClassName="bg-background"
        footer={
          <>
            <Button variant="outline" onClick={() => setCancelMeetingTarget(null)}>
              Keep meeting
            </Button>
            <Button
              variant="danger"
              onClick={() => cancelMeetingTarget && cancelMeeting.mutate(cancelMeetingTarget.id)}
              isLoading={cancelMeeting.isPending}
            >
              Cancel meeting
            </Button>
          </>
        }
      >
        <FormSection>
          <p className="text-label font-semibold">{cancelMeetingTarget?.title}</p>
        </FormSection>
      </Dialog>
    </PageLayout>
  )
}

function OverviewPanel({
  project,
  timelines,
  isLoading,
  isError,
  onRetry,
}: {
  project: ProjectDto
  timelines: {
    id: number
    name: string
    status: string
    start_date: string
    end_date: string
    description: string | null
  }[]
  isLoading: boolean
  isError: boolean
  onRetry: () => void
}) {
  return (
    <div className="wide:grid-cols-[minmax(0,1.5fr)_minmax(17rem,.8fr)] grid min-w-0 gap-4">
      <div className="grid min-w-0 gap-4">
        <Card className="min-w-0">
          <div className="flex flex-wrap items-start justify-between gap-3">
            <div>
              <p className="text-caption text-text-secondary">Project status</p>
              <div className="mt-2 flex flex-wrap gap-2">
                <StatusChip label={labelStatus(project.status)} tone={statusTone(project.status)} />
                {project.is_archived ? <StatusChip label="Archived" tone="neutral" /> : null}
                <StatusChip label={`${project.progress}% complete`} tone="info" />
              </div>
            </div>
            <ProgressBar
              value={project.progress}
              label="Project progress"
              className="tablet:max-w-56 mt-3 w-full"
            />
          </div>
          <p className="text-body-sm text-text-secondary mt-4 whitespace-pre-wrap">
            {project.summary || 'No project summary has been provided.'}
          </p>
        </Card>
        <div className="tablet:grid-cols-2 grid min-w-0 gap-3">
          <DetailCard label="Allocated budget" value={money(project.budget)} detail="NGN" />
          <DetailCard
            label="Spent expenses"
            value={money(project.spent_expense_total)}
            detail={`${project.expense_count} expense records`}
          />
          <DetailCard
            label="Committed expenses"
            value={money(project.committed_expense_total)}
            detail="Approved commitments"
          />
          <DetailCard
            label="Remaining budget"
            value={money(project.remaining_budget)}
            detail="Based on current expense records"
          />
        </div>
        <Card>
          <h2 className="text-h3 font-semibold">Project timeline</h2>
          {isLoading ? (
            <Skeleton className="mt-4 h-20" />
          ) : isError ? (
            <SectionErrorState className="mt-4" onRetry={onRetry} />
          ) : timelines.length ? (
            <div className="divide-border-subtle mt-3 divide-y">
              {timelines.map((timeline) => (
                <div key={timeline.id} className="flex flex-wrap justify-between gap-3 py-3">
                  <div>
                    <p className="text-label font-semibold">{timeline.name}</p>
                    <p className="text-caption text-text-secondary mt-1">
                      {shortDate(timeline.start_date)} – {shortDate(timeline.end_date)}
                    </p>
                  </div>
                  <StatusChip
                    label={labelStatus(timeline.status)}
                    tone={statusTone(timeline.status)}
                    dense
                  />
                </div>
              ))}
            </div>
          ) : (
            <p className="text-body-sm text-text-secondary mt-3">
              No timeline entries have been added yet.
            </p>
          )}
        </Card>
      </div>
      <Card className="h-fit">
        <h2 className="text-h3 font-semibold">Project details</h2>
        <dl className="divide-border-subtle mt-4 divide-y">
          {[
            ['Owning branch', project.branch_name ?? 'Unassigned legacy project'],
            ['Category', project.category],
            ['Client', `Client #${project.client_id}`],
            ['Location', project.location || 'Not provided'],
            ['Start date', shortDate(project.start_date)],
            ['Target completion', shortDate(project.deadline)],
          ].map(([key, value]) => (
            <div key={key} className="flex flex-wrap justify-between gap-2 py-3">
              <dt className="text-caption text-text-secondary">{key}</dt>
              <dd className="text-label text-right font-medium">{value}</dd>
            </div>
          ))}
        </dl>
      </Card>
    </div>
  )
}

function DetailCard({ label, value, detail }: { label: string; value: string; detail: string }) {
  return (
    <Card className="min-w-0">
      <p className="text-caption text-text-secondary">{label}</p>
      <p className="text-h3 mt-1 truncate font-semibold" title={value}>
        {value}
      </p>
      <p className="text-caption text-text-secondary mt-1">{detail}</p>
    </Card>
  )
}

function MembersPanel({
  options,
  isLoading,
  isError,
  selected,
  setSelected,
  onSave,
  saving,
  canEdit,
  retry,
}: {
  options: ProjectEmployeeOptionDto[]
  isLoading: boolean
  isError: boolean
  selected: number[]
  setSelected: (value: number[]) => void
  onSave: () => void
  saving: boolean
  canEdit: boolean
  retry: () => void
}) {
  if (isLoading) return <Skeleton className="h-64" />
  if (isError) return <SectionErrorState onRetry={retry} />
  return (
    <Card>
      <div className="flex flex-wrap items-center justify-between gap-3">
        <div>
          <h2 className="text-h3 font-semibold">Project members</h2>
          <p className="text-caption text-text-secondary mt-1">
            Only active employees assigned to this project's branch can be selected.
          </p>
        </div>
        {canEdit ? (
          <Button onClick={onSave} isLoading={saving}>
            Save team
          </Button>
        ) : null}
      </div>
      {options.length ? (
        <div className="tablet:grid-cols-2 mt-4 grid gap-2">
          {options.map((employee) => (
            <label
              key={employee.id}
              className="border-border-subtle hover:bg-surface-muted rounded-control flex min-w-0 cursor-pointer items-start gap-3 border p-3"
            >
              <input
                type="checkbox"
                checked={selected.includes(employee.id)}
                disabled={!canEdit}
                onChange={(event) =>
                  setSelected(
                    event.target.checked
                      ? [...selected, employee.id]
                      : selected.filter((id) => id !== employee.id),
                  )
                }
                className="accent-primary mt-1 size-4 shrink-0"
              />
              <span className="min-w-0">
                <span className="text-label block truncate font-semibold">{employee.name}</span>
                <span className="text-caption text-text-secondary block truncate">
                  {employee.position || employee.employee_id} · {employee.email}
                </span>
              </span>
            </label>
          ))}
        </div>
      ) : (
        <EmptyState
          title="No eligible employees"
          description="There are no active employees available for the owning branch."
        />
      )}
    </Card>
  )
}

function ListPanel({
  title,
  description,
  isLoading,
  isError,
  onRetry,
  onAdd,
  canAdd,
  addLabel = 'Add item',
  empty,
  children,
}: {
  title: string
  description: string
  isLoading: boolean
  isError: boolean
  onRetry: () => void
  onAdd: () => void
  canAdd: boolean
  addLabel?: string
  empty: string
  children: ReactNode
}) {
  const hasItems = Array.isArray(children) ? children.length > 0 : Boolean(children)
  return (
    <Card className="min-w-0">
      <header className="flex flex-wrap items-center justify-between gap-3">
        <div>
          <h2 className="text-h3 font-semibold">{title}</h2>
          <p className="text-caption text-text-secondary mt-1">{description}</p>
        </div>
        {canAdd ? (
          <Button leadingIcon={<Plus className="size-4" />} onClick={onAdd}>
            {addLabel}
          </Button>
        ) : null}
      </header>
      {isLoading ? (
        <div className="mt-4 grid gap-3">
          <Skeleton className="h-20" />
          <Skeleton className="h-20" />
        </div>
      ) : isError ? (
        <SectionErrorState className="mt-4" onRetry={onRetry} />
      ) : hasItems ? (
        <div className="mt-4 grid min-w-0 gap-3">{children}</div>
      ) : (
        <EmptyState title="Nothing here yet" description={empty} />
      )}
    </Card>
  )
}

function WorksiteCard({
  item,
  canEdit,
  canDelete,
  onEdit,
  onDelete,
}: {
  item: ProjectWorksiteDto
  canEdit: boolean
  canDelete: boolean
  onEdit: () => void
  onDelete: () => void
}) {
  return (
    <Card className="flex min-w-0 flex-wrap items-center justify-between gap-3">
      <div className="min-w-0">
        <p className="text-label font-semibold">{item.name}</p>
        <p className="text-caption text-text-secondary mt-1 flex items-center gap-1">
          <MapPin className="size-3.5" />
          {item.location}
        </p>
        {item.description ? (
          <p className="text-body-sm text-text-secondary mt-2">{item.description}</p>
        ) : null}
      </div>
      <div className="flex items-center gap-2">
        <StatusChip dense label={labelStatus(item.status)} tone={statusTone(item.status)} />
        {canEdit ? (
          <Button variant="outline" size="sm" onClick={onEdit}>
            Edit
          </Button>
        ) : null}
        {canDelete ? (
          <Button variant="danger" size="sm" aria-label={`Delete ${item.name}`} onClick={onDelete}>
            <Trash2 className="size-4" />
          </Button>
        ) : null}
      </div>
    </Card>
  )
}
function MilestoneCard({
  item,
  canEdit,
  canDelete,
  onEdit,
  onDelete,
}: {
  item: ProjectMilestoneDto
  canEdit: boolean
  canDelete: boolean
  onEdit: () => void
  onDelete: () => void
}) {
  return (
    <Card className="min-w-0">
      <div className="flex flex-wrap items-center justify-between gap-3">
        <div className="min-w-0">
          <p className="text-label font-semibold">{item.name}</p>
          <p className="text-caption text-text-secondary mt-1">
            {shortDate(item.start_date)} – {shortDate(item.end_date)} · {money(item.budget)}
          </p>
        </div>
        <span className="flex items-center gap-2">
          <StatusChip dense label={labelStatus(item.status)} tone={statusTone(item.status)} />
          {canEdit ? (
            <Button variant="outline" size="sm" onClick={onEdit}>
              Edit
            </Button>
          ) : null}
          {canDelete ? (
            <Button
              variant="danger"
              size="sm"
              aria-label={`Delete ${item.name}`}
              onClick={onDelete}
            >
              <Trash2 className="size-4" />
            </Button>
          ) : null}
        </span>
      </div>
      <ProgressBar value={item.progress} label={`${item.name} progress`} className="mt-3" />
      {item.description ? (
        <p className="text-body-sm text-text-secondary mt-3">{item.description}</p>
      ) : null}
    </Card>
  )
}
function TaskCard({
  item,
  milestone,
  canEdit,
  canDelete,
  onEdit,
  onDelete,
}: {
  item: ProjectTaskDto
  milestone?: string
  canEdit: boolean
  canDelete: boolean
  onEdit: () => void
  onDelete: () => void
}) {
  return (
    <Card className="flex min-w-0 flex-wrap items-center justify-between gap-3">
      <div className="min-w-0">
        <p className="text-label font-semibold">{item.name}</p>
        <p className="text-caption text-text-secondary mt-1">
          {milestone ? `${milestone} · ` : ''}Due {shortDate(item.due_date)}
          {item.estimated_hours ? ` · ${item.estimated_hours}h` : ''}
        </p>
        {item.description ? (
          <p className="text-body-sm text-text-secondary mt-2">{item.description}</p>
        ) : null}
      </div>
      <span className="flex items-center gap-2">
        <StatusChip dense label={labelStatus(item.status)} tone={statusTone(item.status)} />
        {canEdit ? (
          <Button variant="outline" size="sm" onClick={onEdit}>
            Edit
          </Button>
        ) : null}
        {canDelete ? (
          <Button variant="danger" size="sm" aria-label={`Delete ${item.name}`} onClick={onDelete}>
            <Trash2 className="size-4" />
          </Button>
        ) : null}
      </span>
    </Card>
  )
}
function AssociateCard({
  item,
  canDelete,
  onDelete,
}: {
  item: ProjectAssociateDto
  canDelete: boolean
  onDelete: () => void
}) {
  return (
    <Card className="flex min-w-0 flex-wrap items-center justify-between gap-3">
      <div>
        <p className="text-label font-semibold">{item.name}</p>
        <p className="text-caption text-text-secondary mt-1">
          {item.code ?? 'Partner'} · {item.category} · Role: {item.project_role}
        </p>
      </div>
      {canDelete ? (
        <Button variant="outline" size="sm" onClick={onDelete}>
          Remove associate
        </Button>
      ) : null}
    </Card>
  )
}
function MeetingCard({
  item,
  canEdit,
  canCancel,
  onEdit,
  onCancel,
}: {
  item: ProjectMeetingDto
  canEdit: boolean
  canCancel: boolean
  onEdit: () => void
  onCancel: () => void
}) {
  return (
    <Card className="flex min-w-0 flex-wrap items-center justify-between gap-3">
      <div className="min-w-0">
        <p className="text-label font-semibold">{item.title}</p>
        <p className="text-caption text-text-secondary mt-1 flex items-center gap-1">
          <CalendarDays className="size-3.5" />
          {shortDate(item.meeting_date)} at {item.meeting_time} · {item.duration_display}
        </p>
        <p className="text-caption text-text-secondary mt-1">
          {item.location_type_display}
          {item.location ? ` · ${item.location}` : ''} · {item.attendee_count} attendees
        </p>
      </div>
      <span className="flex items-center gap-2">
        <StatusChip dense label={labelStatus(item.status)} tone={statusTone(item.status)} />
        {canEdit ? (
          <Button variant="ghost" size="sm" onClick={onEdit}>
            Edit
          </Button>
        ) : null}
        {canCancel && item.status !== 'cancelled' ? (
          <Button variant="outline" size="sm" onClick={onCancel}>
            Cancel meeting
          </Button>
        ) : null}
      </span>
    </Card>
  )
}

function EntryDialog({
  open,
  entry,
  milestones,
  associates,
  saving,
  onClose,
  onSave,
}: {
  open: boolean
  entry: EntryDraft | null
  milestones: ProjectMilestoneDto[]
  associates: ProjectAssociateOptionDto[]
  saving: boolean
  onClose: () => void
  onSave: (values: Record<string, string>) => Promise<void>
}) {
  const [values, setValues] = useState<Record<string, string>>(() => entry?.values ?? {})
  if (!entry) return null
  const kind = entry.kind
  const title = `${entry.recordId ? 'Edit' : 'Add'} ${kind === 'worksite' ? 'worksite' : kind === 'associate' ? 'associate' : kind}`
  const dialogSize = kind === 'associate' ? 'sm' : kind === 'worksite' ? 'md' : 'lg'
  function textField(
    key: string,
    label: string,
    options: { required?: boolean; type?: string; multiline?: boolean } = {},
  ) {
    return (
      <FormControl
        key={key}
        id={`entry-${key}`}
        label={label}
        required={options.required}
        className={
          key === 'description' || key === 'agenda' || key === 'notes' ? 'tablet:col-span-2' : ''
        }
      >
        {options.multiline ? (
          <TextArea
            required={options.required}
            rows={3}
            value={values[key] ?? ''}
            onChange={(event) => setValues({ ...values, [key]: event.target.value })}
          />
        ) : (
          <TextInput
            required={options.required}
            type={options.type ?? 'text'}
            value={values[key] ?? ''}
            onChange={(event) => setValues({ ...values, [key]: event.target.value })}
          />
        )}
      </FormControl>
    )
  }
  function selectField(key: string, label: string, options: { value: string; label: string }[]) {
    return (
      <DropdownSelect
        key={key}
        label={label}
        value={values[key] ?? ''}
        options={options}
        onChange={(value) => setValues({ ...values, [key]: value })}
      />
    )
  }
  async function submit(event: FormEvent) {
    event.preventDefault()
    await onSave(values)
  }
  return (
    <Dialog
      open={open}
      onOpenChange={(next) => {
        if (!next) onClose()
      }}
      title={title}
      description="Changes are saved to this project and remain branch-scoped."
      size={dialogSize}
      compactOnMobile
      fitContent
      bodyClassName="bg-background"
      footer={
        <>
          <Button variant="outline" onClick={onClose}>
            Cancel
          </Button>
          <Button type="submit" form="project-entry-form" isLoading={saving}>
            {entry.recordId ? 'Save changes' : `Add ${kind}`}
          </Button>
        </>
      }
    >
      <form id="project-entry-form" onSubmit={(event) => void submit(event)} className="min-w-0">
        <FormSection
          aria-label={`${title} details`}
          className="tablet:grid-cols-2 grid min-w-0 gap-4"
        >
          {kind === 'worksite' ? (
            <>
              {textField('name', 'Worksite name', { required: true })}
              {textField('location', 'Location', { required: true })}
              {selectField(
                'status',
                'Status',
                ['setup', 'active', 'inactive', 'completed'].map((value) => ({
                  value,
                  label: labelStatus(value),
                })),
              )}
              {textField('description', 'Description', { multiline: true })}
            </>
          ) : null}
          {kind === 'milestone' ? (
            <>
              {textField('name', 'Milestone name', { required: true })}
              {selectField(
                'status',
                'Status',
                ['pending', 'in_progress', 'completed', 'delayed'].map((value) => ({
                  value,
                  label: labelStatus(value),
                })),
              )}
              {selectField(
                'priority',
                'Priority',
                ['low', 'medium', 'high'].map((value) => ({ value, label: labelStatus(value) })),
              )}
              {textField('progress', 'Progress (%)', { type: 'number' })}
              {textField('budget', 'Budget (NGN)', { type: 'number' })}
              {textField('start_date', 'Start date', { type: 'date' })}
              {textField('end_date', 'End date', { type: 'date' })}
              {textField('description', 'Description', { multiline: true })}
            </>
          ) : null}
          {kind === 'task' ? (
            <>
              {textField('name', 'Task name', { required: true })}
              {selectField(
                'status',
                'Status',
                ['pending', 'in_progress', 'completed', 'cancelled'].map((value) => ({
                  value,
                  label: labelStatus(value),
                })),
              )}
              {selectField(
                'priority',
                'Priority',
                ['low', 'medium', 'high', 'critical'].map((value) => ({
                  value,
                  label: labelStatus(value),
                })),
              )}
              {selectField('milestone_id', 'Milestone', [
                { value: '', label: 'No milestone' },
                ...milestones.map((item) => ({ value: String(item.id), label: item.name })),
              ])}
              {textField('due_date', 'Due date', { type: 'date' })}
              {textField('estimated_hours', 'Estimated hours', { type: 'number' })}
              {textField('description', 'Description', { multiline: true })}
            </>
          ) : null}
          {kind === 'meeting' ? (
            <>
              {textField('title', 'Meeting title', { required: true })}
              {textField('meeting_date', 'Date', { required: true, type: 'date' })}
              {textField('meeting_time', 'Time', { required: true, type: 'time' })}
              {textField('duration_minutes', 'Duration (minutes)', { type: 'number' })}
              {selectField('location_type', 'Meeting type', [
                { value: 'physical', label: 'In person' },
                { value: 'virtual', label: 'Virtual' },
                { value: 'hybrid', label: 'Hybrid' },
              ])}
              {selectField(
                'status',
                'Status',
                ['scheduled', 'ongoing', 'completed', 'postponed', 'cancelled'].map((value) => ({
                  value,
                  label: labelStatus(value),
                })),
              )}
              {textField('location', 'Location or meeting link')}
              {textField('agenda', 'Agenda', { required: true, multiline: true })}
              {textField('notes', 'Notes', { multiline: true })}
            </>
          ) : null}
          {kind === 'associate' ? (
            <>
              <DropdownSelect
                label="Partner"
                value={values.partner_id ?? ''}
                placeholder="Select a partner"
                searchable
                options={associates.map((item) => ({
                  value: String(item.id),
                  label: item.name,
                  description: [item.code, item.category].filter(Boolean).join(' · '),
                }))}
                onChange={(value) => setValues({ ...values, partner_id: value })}
                required
              />
              {textField('project_role', 'Role on this project', { required: true })}
            </>
          ) : null}
        </FormSection>
      </form>
    </Dialog>
  )
}

function worksiteDraft(item: ProjectWorksiteDto) {
  return {
    name: item.name,
    location: item.location,
    status: item.status,
    description: item.description ?? '',
  }
}
function milestoneDraft(item: ProjectMilestoneDto) {
  return {
    name: item.name,
    description: item.description ?? '',
    status: item.status,
    priority: item.priority,
    progress: String(item.progress),
    budget: item.budget ?? '',
    start_date: item.start_date ?? '',
    end_date: item.end_date ?? '',
  }
}
function taskDraft(item: ProjectTaskDto) {
  return {
    name: item.name,
    description: item.description ?? '',
    status: item.status,
    priority: item.priority,
    due_date: item.due_date ?? '',
    estimated_hours: item.estimated_hours ?? '',
    milestone_id: item.milestone_id ? String(item.milestone_id) : '',
  }
}
function formatBytes(value: number) {
  return value < 1024 * 1024
    ? `${Math.max(1, Math.round(value / 1024))} KB`
    : `${(value / (1024 * 1024)).toFixed(1)} MB`
}
