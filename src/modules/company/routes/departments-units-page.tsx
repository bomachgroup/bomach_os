import { keepPreviousData, useMutation, useQuery, useQueryClient } from '@tanstack/react-query'
import { useNavigate, useSearch } from '@tanstack/react-router'
import { Building2, ChevronLeft, ChevronRight, Layers3, Pencil, Plus, Search } from 'lucide-react'
import { useCallback, useEffect, useMemo, useState, type FormEvent } from 'react'

import {
  companyOrganizationApi,
  companyOrganizationQueryKeys,
  type DepartmentDto,
  type DepartmentUnitDto,
  type UnitListParams,
} from '@/modules/company/company-organization.api'
import { complianceQueryKeys } from '@/modules/company/governance.api'
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

import type { DepartmentSearch } from '../company-organization.search'
import { departmentCategoryLabel } from '../organization-labels'

type CatalogTab = 'departments' | 'units'
type EditorState =
  | { kind: 'department'; value: DepartmentDto | null }
  | { kind: 'unit'; value: DepartmentUnitDto | null }
  | null

const PAGE_SIZE = 10

function SearchInput({ search, onCommit }: { search: string; onCommit: (value: string) => void }) {
  const [value, setValue] = useState(search)
  useEffect(() => {
    const next = value.trim()
    if (next === search) return
    const timer = window.setTimeout(() => onCommit(next), 250)
    return () => window.clearTimeout(timer)
  }, [onCommit, search, value])

  return (
    <FormControl id="organization-search" label="Search this list">
      <div className="relative">
        <Search
          className="text-text-muted absolute top-1/2 left-3.5 size-4 -translate-y-1/2"
          aria-hidden="true"
        />
        <TextInput
          id="organization-search"
          type="search"
          value={value}
          onChange={(event) => setValue(event.currentTarget.value)}
          placeholder="Search by name or description"
          className="pl-10"
        />
      </div>
    </FormControl>
  )
}

function Description({ value }: { value: string }) {
  return value.trim() ? (
    <p className="text-body-sm text-text-secondary mt-1 line-clamp-2">{value}</p>
  ) : (
    <p className="text-caption text-text-muted mt-1">No description added</p>
  )
}

function duplicateAwareFormError(error: unknown, duplicateMessage: string) {
  const message = presentError(error, 'form-submit').message
  return /already exists|__all__|%\([^)]*\)s|unique constraint/i.test(message)
    ? duplicateMessage
    : message
}

function DepartmentEditor({
  value,
  usedNames,
  userId,
  employeeId,
  isSaving,
  onClose,
  onSave,
}: {
  value: DepartmentDto | null
  usedNames: Set<string>
  userId: number
  employeeId: string
  isSaving: boolean
  onClose: () => void
  onSave: (input: { name: string; description: string }) => Promise<unknown>
}) {
  const [name, setName] = useState(value?.name ?? '')
  const [description, setDescription] = useState(value?.description ?? '')
  const [error, setError] = useState('')
  const choices = useQuery({
    queryKey: companyOrganizationQueryKeys.departmentChoices(userId, employeeId),
    queryFn: ({ signal }) => companyOrganizationApi.departmentChoices(signal),
    staleTime: DATA_FRESHNESS_MS.reference,
    refetchOnWindowFocus: true,
    refetchOnReconnect: true,
  })

  async function submit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault()
    setError('')
    if (!name) {
      setError('Choose a department category.')
      return
    }
    if (usedNames.has(name) && name !== value?.name) {
      setError('That department category already exists.')
      return
    }
    try {
      await onSave({ name, description: description.trim() })
      onClose()
    } catch (cause) {
      setError(duplicateAwareFormError(cause, 'That department category already exists.'))
    }
  }

  const options: DropdownSelectOption[] = (choices.data?.items ?? []).map((choice) => ({
    ...choice,
    label: departmentCategoryLabel(choice.value),
    disabled: usedNames.has(choice.value) && choice.value !== value?.name,
  }))
  const hasAvailableCategory = options.some((option) => !option.disabled)

  return (
    <Dialog
      open
      onOpenChange={(open) => !open && onClose()}
      title={value ? 'Edit department' : 'Add department'}
      description="Add a supported category and its purpose."
      size="sm"
      fitContent
      closeLabel="Close department editor"
      footer={
        <>
          <Button variant="outline" onClick={onClose}>
            Cancel
          </Button>
          <Button
            type="submit"
            form="department-editor-form"
            isLoading={isSaving}
            disabled={choices.isPending || !choices.data || !hasAvailableCategory}
          >
            Save department
          </Button>
        </>
      }
    >
      <form
        id="department-editor-form"
        onSubmit={(event) => void submit(event)}
        className="space-y-4"
      >
        {choices.isError && !choices.data ? (
          <SectionErrorState
            error={choices.error}
            title="Department categories could not be loaded"
            onRetry={() => void choices.refetch()}
          />
        ) : null}
        {!value && choices.data && !hasAvailableCategory ? (
          <Alert tone="info" role="status" className="px-3 py-2.5">
            All supported department categories are already in use. Edit an existing department to
            change its description.
          </Alert>
        ) : null}
        {error ? (
          <Alert tone="danger" role="alert">
            {error}
          </Alert>
        ) : null}
        <FormSection className="space-y-4">
          <div>
            <h3 className="text-label font-semibold">Department identity</h3>
            <p className="text-caption text-text-secondary mt-1">
              Choose the category and describe the work this department owns.
            </p>
          </div>
          <div className="space-y-4">
            <FormControl id="department-name" label="Department category" required>
              <DropdownSelect
                id="department-name"
                value={name}
                options={options}
                onChange={(nextName) => {
                  setName(nextName)
                  setError('')
                }}
                placeholder="Select a department"
                searchable
                aria-label="Department category"
              />
            </FormControl>
            <FormControl id="department-description" label="Description">
              <TextArea
                id="department-description"
                value={description}
                onChange={(event) => {
                  setDescription(event.currentTarget.value)
                  setError('')
                }}
                placeholder="Describe this department’s responsibilities"
                rows={3}
              />
            </FormControl>
          </div>
        </FormSection>
      </form>
    </Dialog>
  )
}

function UnitEditor({
  value,
  departments,
  departmentsLoading,
  departmentsError,
  onRetryDepartments,
  isSaving,
  onClose,
  onSave,
}: {
  value: DepartmentUnitDto | null
  departments: DepartmentDto[]
  departmentsLoading: boolean
  departmentsError?: unknown
  onRetryDepartments: () => void
  isSaving: boolean
  onClose: () => void
  onSave: (input: { name: string; department_id: number; description: string }) => Promise<unknown>
}) {
  const [name, setName] = useState(value?.name ?? '')
  const [departmentId, setDepartmentId] = useState(value ? String(value.department_id) : '')
  const [description, setDescription] = useState(value?.description ?? '')
  const [error, setError] = useState('')
  const departmentOptions = departments.map((department) => ({
    value: String(department.id),
    label: departmentCategoryLabel(department.name),
  }))

  async function submit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault()
    setError('')
    if (name.trim().length < 2) {
      setError('Enter a unit name with at least two characters.')
      return
    }
    if (!departmentId) {
      setError('Choose a parent department.')
      return
    }
    try {
      await onSave({
        name: name.trim(),
        department_id: Number(departmentId),
        description: description.trim(),
      })
      onClose()
    } catch (cause) {
      setError(
        duplicateAwareFormError(
          cause,
          'A unit with this name already exists in the selected department.',
        ),
      )
    }
  }

  return (
    <Dialog
      open
      onOpenChange={(open) => !open && onClose()}
      title={value ? 'Edit unit' : 'Add unit'}
      description="Add a unit to its parent department."
      size="sm"
      fitContent
      closeLabel="Close unit editor"
      footer={
        <>
          <Button variant="outline" onClick={onClose}>
            Cancel
          </Button>
          <Button
            type="submit"
            form="unit-editor-form"
            isLoading={isSaving}
            disabled={departmentsLoading || !departments.length}
          >
            Save unit
          </Button>
        </>
      }
    >
      <form id="unit-editor-form" onSubmit={(event) => void submit(event)} className="space-y-4">
        {departmentsLoading ? <Skeleton className="h-10 w-full" /> : null}
        {!departmentsLoading && departments.length === 0 ? (
          departmentsError ? (
            <SectionErrorState error={departmentsError} onRetry={onRetryDepartments} />
          ) : (
            <Alert tone="warning" role="status">
              Add a department first. Department list access is required to choose a parent.
            </Alert>
          )
        ) : null}
        {error ? (
          <Alert tone="danger" role="alert">
            {error}
          </Alert>
        ) : null}
        {departments.length ? (
          <FormSection className="space-y-4">
            <div>
              <h3 className="text-label font-semibold">Unit identity</h3>
              <p className="text-caption text-text-secondary mt-1">
                Name the unit and connect it to one department.
              </p>
            </div>
            <div className="phone:grid-cols-2 grid gap-4">
              <FormControl id="unit-name" label="Unit name" required>
                <TextInput
                  id="unit-name"
                  value={name}
                  onChange={(event) => {
                    setName(event.currentTarget.value)
                    setError('')
                  }}
                  autoComplete="off"
                  maxLength={100}
                />
              </FormControl>
              <FormControl id="unit-department" label="Parent department" required>
                <DropdownSelect
                  id="unit-department"
                  value={departmentId}
                  options={departmentOptions}
                  onChange={(nextDepartmentId) => {
                    setDepartmentId(nextDepartmentId)
                    setError('')
                  }}
                  placeholder="Select a department"
                  searchable
                  aria-label="Parent department"
                />
              </FormControl>
              <FormControl id="unit-description" label="Description" className="phone:col-span-2">
                <TextArea
                  id="unit-description"
                  value={description}
                  onChange={(event) => {
                    setDescription(event.currentTarget.value)
                    setError('')
                  }}
                  placeholder="Describe this unit’s focus"
                  rows={3}
                />
              </FormControl>
            </div>
          </FormSection>
        ) : null}
      </form>
    </Dialog>
  )
}

function Pagination({
  page,
  total,
  onPageChange,
}: {
  page: number
  total: number
  onPageChange: (page: number) => void
}) {
  const pageCount = Math.max(1, Math.ceil(total / PAGE_SIZE))
  return (
    <div className="border-border-subtle flex flex-wrap items-center justify-between gap-3 border-t pt-4">
      <p className="text-caption text-text-secondary">
        {total === 0 ? 'No records' : `Page ${page} of ${pageCount} · ${total} total`}
      </p>
      <div className="flex gap-2">
        <Button
          variant="outline"
          size="sm"
          disabled={page <= 1}
          onClick={() => onPageChange(page - 1)}
          leadingIcon={<ChevronLeft className="size-4" aria-hidden="true" />}
        >
          Previous
        </Button>
        <Button
          variant="outline"
          size="sm"
          disabled={page >= pageCount}
          onClick={() => onPageChange(page + 1)}
          leadingIcon={<ChevronRight className="size-4" aria-hidden="true" />}
        >
          Next
        </Button>
      </div>
    </div>
  )
}

export function DepartmentsUnitsPage() {
  const queryClient = useQueryClient()
  const { showToast } = useToast()
  const sessionQuery = useQuery(authSessionQueryOptions())
  const session = sessionQuery.data
  const userId = session?.user.id ?? 0
  const employeeId = session?.employee.employee_id ?? ''
  const search = useSearch({ from: '/_protected/company/department' }) as DepartmentSearch
  const navigate = useNavigate()
  const [editor, setEditor] = useState<EditorState>(null)
  const canListDepartments = hasPermission(session?.permissions ?? {}, 'departments', 'list')
  const canListUnits = hasPermission(session?.permissions ?? {}, 'department_units', 'list')
  const canCreateDepartment = hasPermission(session?.permissions ?? {}, 'departments', 'create')
  const canUpdateDepartment = hasPermission(session?.permissions ?? {}, 'departments', 'update')
  const canCreateUnit = hasPermission(session?.permissions ?? {}, 'department_units', 'create')
  const canUpdateUnit = hasPermission(session?.permissions ?? {}, 'department_units', 'update')
  const activeTab: CatalogTab = search.tab
  const offset = (search.page - 1) * PAGE_SIZE
  const departmentParams = useMemo(
    () => ({ limit: PAGE_SIZE, offset, search: search.search }),
    [offset, search.search],
  )
  const unitParams: UnitListParams = useMemo(
    () => ({
      limit: PAGE_SIZE,
      offset,
      search: search.search,
      departmentId: search.departmentId === 'all' ? null : Number(search.departmentId),
    }),
    [offset, search.departmentId, search.search],
  )

  useEffect(() => {
    if (!session) return
    if (activeTab === 'departments' && !canListDepartments && canListUnits) {
      void navigate({
        to: '/company/department',
        search: (previous: DepartmentSearch) => ({ ...previous, tab: 'units', page: 1 }),
        replace: true,
      })
    } else if (activeTab === 'units' && !canListUnits && canListDepartments) {
      void navigate({
        to: '/company/department',
        search: (previous: DepartmentSearch) => ({ ...previous, tab: 'departments', page: 1 }),
        replace: true,
      })
    }
  }, [activeTab, canListDepartments, canListUnits, navigate, session])

  const departments = useQuery({
    queryKey: companyOrganizationQueryKeys.departments(userId, employeeId, departmentParams),
    queryFn: ({ signal }) => companyOrganizationApi.departments(departmentParams, signal),
    enabled: Boolean(session && canListDepartments && activeTab === 'departments'),
    staleTime: DATA_FRESHNESS_MS.reference,
    refetchOnMount: true,
    refetchOnWindowFocus: true,
    refetchOnReconnect: true,
    placeholderData: keepPreviousData,
  })
  const units = useQuery({
    queryKey: companyOrganizationQueryKeys.units(userId, employeeId, unitParams),
    queryFn: ({ signal }) => companyOrganizationApi.units(unitParams, signal),
    enabled: Boolean(session && canListUnits && activeTab === 'units'),
    staleTime: DATA_FRESHNESS_MS.reference,
    refetchOnMount: true,
    refetchOnWindowFocus: true,
    refetchOnReconnect: true,
    placeholderData: keepPreviousData,
  })
  const allDepartmentsParams = useMemo(() => ({ limit: 100, offset: 0, search: '' }), [])
  const allDepartments = useQuery({
    queryKey: companyOrganizationQueryKeys.departments(userId, employeeId, allDepartmentsParams),
    queryFn: ({ signal }) => companyOrganizationApi.departments(allDepartmentsParams, signal),
    enabled: Boolean(session && canListDepartments),
    staleTime: DATA_FRESHNESS_MS.reference,
    refetchOnMount: true,
    refetchOnWindowFocus: true,
    refetchOnReconnect: true,
  })

  const createDepartment = useMutation({
    mutationFn: (input: { name: string; description: string }) =>
      companyOrganizationApi.createDepartment(input),
    onSuccess: async () => {
      await Promise.all([
        queryClient.invalidateQueries({
          queryKey: [...companyOrganizationQueryKeys.scoped(userId, employeeId), 'departments'],
        }),
        queryClient.invalidateQueries({
          queryKey: [
            ...companyOrganizationQueryKeys.scoped(userId, employeeId),
            'department-choices',
          ],
        }),
        queryClient.invalidateQueries({
          queryKey: complianceQueryKeys.departments(userId, employeeId),
        }),
      ])
      showToast({
        title: 'Department added',
        description: 'The department catalog has been updated.',
      })
    },
  })
  const updateDepartment = useMutation({
    mutationFn: ({ id, input }: { id: number; input: { name: string; description: string } }) =>
      companyOrganizationApi.updateDepartment(id, input),
    onSuccess: async () => {
      await Promise.all([
        queryClient.invalidateQueries({
          queryKey: [...companyOrganizationQueryKeys.scoped(userId, employeeId), 'departments'],
        }),
        queryClient.invalidateQueries({
          queryKey: [...companyOrganizationQueryKeys.scoped(userId, employeeId), 'units'],
        }),
        queryClient.invalidateQueries({
          queryKey: [
            ...companyOrganizationQueryKeys.scoped(userId, employeeId),
            'department-choices',
          ],
        }),
        queryClient.invalidateQueries({
          queryKey: [...companyOrganizationQueryKeys.scoped(userId, employeeId), 'reporting-chart'],
        }),
        queryClient.invalidateQueries({
          queryKey: complianceQueryKeys.departments(userId, employeeId),
        }),
        queryClient.invalidateQueries({
          queryKey: complianceQueryKeys.lists(userId, employeeId),
        }),
      ])
      showToast({ title: 'Department saved', description: 'Department details have been updated.' })
    },
  })
  const createUnit = useMutation({
    mutationFn: (input: { name: string; department_id: number; description: string }) =>
      companyOrganizationApi.createUnit(input),
    onSuccess: async () => {
      await queryClient.invalidateQueries({
        queryKey: [...companyOrganizationQueryKeys.scoped(userId, employeeId), 'units'],
      })
      showToast({ title: 'Unit added', description: 'The department unit list has been updated.' })
    },
  })
  const updateUnit = useMutation({
    mutationFn: ({
      id,
      input,
    }: {
      id: number
      input: { name: string; department_id: number; description: string }
    }) => companyOrganizationApi.updateUnit(id, input),
    onSuccess: async () => {
      await queryClient.invalidateQueries({
        queryKey: [...companyOrganizationQueryKeys.scoped(userId, employeeId), 'units'],
      })
      await queryClient.invalidateQueries({
        queryKey: [...companyOrganizationQueryKeys.scoped(userId, employeeId), 'reporting-chart'],
      })
      showToast({ title: 'Unit saved', description: 'Unit details have been updated.' })
    },
  })

  const commitSearch = useCallback(
    (value: string) => {
      void navigate({
        to: '/company/department',
        search: (previous: DepartmentSearch) => ({ ...previous, search: value, page: 1 }),
        replace: true,
      })
    },
    [navigate],
  )
  const changePage = useCallback(
    (page: number) => {
      void navigate({
        to: '/company/department',
        search: (previous: DepartmentSearch) => ({ ...previous, page }),
        replace: true,
      })
    },
    [navigate],
  )
  const changeTab = useCallback(
    (tab: CatalogTab) => {
      void navigate({
        to: '/company/department',
        search: (previous: DepartmentSearch) => ({ ...previous, tab, search: '', page: 1 }),
        replace: false,
      })
    },
    [navigate],
  )

  const activePageCount = activeTab === 'departments' ? departments.data?.count : units.data?.count
  const activePageIsRefreshing =
    activeTab === 'departments' ? departments.isFetching : units.isFetching
  const activePageIsPlaceholder =
    activeTab === 'departments' ? departments.isPlaceholderData : units.isPlaceholderData

  useEffect(() => {
    if (activePageCount === undefined || activePageIsRefreshing || activePageIsPlaceholder) {
      return
    }
    const lastPage = Math.max(1, Math.ceil(activePageCount / PAGE_SIZE))
    if (search.page > lastPage) changePage(lastPage)
  }, [activePageCount, activePageIsPlaceholder, activePageIsRefreshing, changePage, search.page])

  const departmentItems = departments.data?.items ?? []
  const unitItems = units.data?.items ?? []
  const departmentOptions: DropdownSelectOption[] = useMemo(
    () => [
      { value: 'all', label: 'All departments' },
      ...(allDepartments.data?.items ?? []).map((item) => ({
        value: String(item.id),
        label: departmentCategoryLabel(item.name),
      })),
    ],
    [allDepartments.data?.items],
  )
  const usedNames = new Set((allDepartments.data?.items ?? []).map((item) => item.name))

  return (
    <PageLayout
      title="Departments & Units"
      subtitle="Maintain the department catalog and its units."
    >
      <div className="space-y-5">
        <Card className="phone:p-5 space-y-4 p-4">
          <div className="flex flex-wrap items-center justify-between gap-3">
            <div>
              <h2 className="text-h3 font-semibold">Organization catalog</h2>
              <p className="text-caption text-text-secondary mt-1">
                Departments use a fixed category list. Units belong to one department.
              </p>
            </div>
            {activeTab === 'departments' && canCreateDepartment ? (
              <Button
                size="sm"
                onClick={() => setEditor({ kind: 'department', value: null })}
                leadingIcon={<Plus className="size-4" aria-hidden="true" />}
              >
                Add department
              </Button>
            ) : null}
            {activeTab === 'units' && canCreateUnit && canListDepartments ? (
              <Button
                size="sm"
                onClick={() => setEditor({ kind: 'unit', value: null })}
                disabled={!canListDepartments || !allDepartments.data?.items.length}
                leadingIcon={<Plus className="size-4" aria-hidden="true" />}
              >
                Add unit
              </Button>
            ) : null}
          </div>
          <div
            className={`border-border-subtle grid w-full gap-1 border-b ${canListDepartments && canListUnits ? 'grid-cols-2' : 'grid-cols-1'}`}
            role="group"
            aria-label="Organization catalog view"
          >
            {canListDepartments ? (
              <button
                type="button"
                aria-pressed={activeTab === 'departments'}
                onClick={() => changeTab('departments')}
                className={`text-body-sm focus-visible:ring-primary w-full border-b-2 px-3 py-2 text-center font-semibold focus-visible:ring-2 focus-visible:outline-none ${activeTab === 'departments' ? 'border-primary text-primary' : 'text-text-secondary hover:text-text-primary border-transparent'}`}
              >
                Departments
              </button>
            ) : null}
            {canListUnits ? (
              <button
                type="button"
                aria-pressed={activeTab === 'units'}
                onClick={() => changeTab('units')}
                className={`text-body-sm focus-visible:ring-primary w-full border-b-2 px-3 py-2 text-center font-semibold focus-visible:ring-2 focus-visible:outline-none ${activeTab === 'units' ? 'border-primary text-primary' : 'text-text-secondary hover:text-text-primary border-transparent'}`}
              >
                Units
              </button>
            ) : null}
          </div>
          <div className="phone:grid-cols-2 grid min-w-0 grid-cols-1 gap-3">
            <SearchInput key={search.search} search={search.search} onCommit={commitSearch} />
            {activeTab === 'units' ? (
              <FormControl id="unit-department-filter" label="Department">
                <DropdownSelect
                  id="unit-department-filter"
                  value={search.departmentId}
                  options={departmentOptions}
                  onChange={(value) =>
                    void navigate({
                      to: '/company/department',
                      search: (previous: DepartmentSearch) => ({
                        ...previous,
                        departmentId: value,
                        page: 1,
                      }),
                      replace: true,
                    })
                  }
                  placeholder="All departments"
                  searchable
                  aria-label="Filter units by department"
                />
              </FormControl>
            ) : (
              <div className="flex items-end">
                {departments.data ? (
                  <p className="text-caption text-text-secondary">
                    {departments.data.count} saved department categories
                  </p>
                ) : null}
              </div>
            )}
          </div>

          {activeTab === 'units' && !canListDepartments && (canCreateUnit || canUpdateUnit) ? (
            <Alert tone="warning" role="status">
              Department list access is needed to choose or verify a unit’s parent department. Unit
              records remain available in read-only mode.
            </Alert>
          ) : null}
          {activeTab === 'units' && canListDepartments && allDepartments.isError ? (
            <SectionErrorState
              error={allDepartments.error}
              title="Department choices could not be loaded"
              onRetry={() => void allDepartments.refetch()}
              className={allDepartments.data ? 'py-2' : undefined}
            />
          ) : null}
          {activeTab === 'units' &&
          canCreateUnit &&
          canListDepartments &&
          allDepartments.data &&
          allDepartments.data.items.length === 0 ? (
            <Alert tone="info" role="status">
              Add a department before creating a unit.
            </Alert>
          ) : null}

          {activeTab === 'departments' ? (
            <>
              {departments.isError && !departments.data ? (
                <SectionErrorState
                  error={departments.error}
                  onRetry={() => void departments.refetch()}
                />
              ) : null}
              {departments.isError && departments.data ? (
                <SectionErrorState
                  error={departments.error}
                  onRetry={() => void departments.refetch()}
                  className="py-2"
                />
              ) : null}
              {departments.isPending ? (
                <div className="space-y-3">
                  <Skeleton className="h-16 w-full" />
                  <Skeleton className="h-16 w-full" />
                </div>
              ) : null}
              {departments.data && departmentItems.length === 0 && departments.data.count === 0 ? (
                <EmptyState
                  title="No departments found"
                  description="Try a different search or add one of the supported categories."
                  icon={<Building2 className="size-6" />}
                />
              ) : null}
              {departments.data && departmentItems.length === 0 && departments.data.count > 0 ? (
                <EmptyState
                  title="This page is outside the available results"
                  description={`${departments.data.count} department categories are available. Return to page ${Math.max(1, Math.ceil(departments.data.count / PAGE_SIZE))} to see them.`}
                  action={
                    <Button
                      variant="outline"
                      onClick={() =>
                        changePage(Math.max(1, Math.ceil(departments.data!.count / PAGE_SIZE)))
                      }
                    >
                      Go to available page
                    </Button>
                  }
                  icon={<Building2 className="size-6" />}
                />
              ) : null}
              {departmentItems.length ? (
                <>
                  <div className="rounded-control border-border-subtle tablet:block hidden overflow-hidden border">
                    <table className="w-full text-left">
                      <thead className="bg-surface-muted text-caption text-text-secondary">
                        <tr>
                          <th className="px-4 py-3 font-semibold">Department</th>
                          <th className="px-4 py-3 font-semibold">Description</th>
                          <th className="px-4 py-3 text-right font-semibold">Action</th>
                        </tr>
                      </thead>
                      <tbody>
                        {departmentItems.map((department) => (
                          <tr key={department.id} className="border-border-subtle border-t">
                            <td className="text-body-sm px-4 py-3 font-semibold">
                              {departmentCategoryLabel(department.name)}
                            </td>
                            <td className="text-body-sm text-text-secondary px-4 py-3">
                              {department.description || '—'}
                            </td>
                            <td className="px-4 py-2 text-right">
                              {canUpdateDepartment ? (
                                <Button
                                  variant="ghost"
                                  size="sm"
                                  aria-label={`Edit ${departmentCategoryLabel(department.name)} department`}
                                  onClick={() =>
                                    setEditor({ kind: 'department', value: department })
                                  }
                                  leadingIcon={<Pencil className="size-3.5" aria-hidden="true" />}
                                >
                                  Edit
                                </Button>
                              ) : null}
                            </td>
                          </tr>
                        ))}
                      </tbody>
                    </table>
                  </div>
                  <div className="tablet:hidden space-y-3">
                    {departmentItems.map((department) => (
                      <Card
                        key={department.id}
                        className="phone:p-4 grid min-w-0 grid-cols-[auto_minmax(0,1fr)_auto] items-start gap-3 p-3"
                      >
                        <span className="bg-primary-subtle/70 text-primary rounded-control mt-0.5 flex size-9 shrink-0 items-center justify-center">
                          <Building2 className="size-[18px]" aria-hidden="true" />
                        </span>
                        <div className="min-w-0 flex-1">
                          <h3 className="text-body-sm text-text-primary font-semibold">
                            {departmentCategoryLabel(department.name)}
                          </h3>
                          <Description value={department.description} />
                        </div>
                        {canUpdateDepartment ? (
                          <Button
                            variant="outline"
                            size="sm"
                            aria-label={`Edit ${departmentCategoryLabel(department.name)}`}
                            onClick={() => setEditor({ kind: 'department', value: department })}
                            leadingIcon={<Pencil className="size-3.5" aria-hidden="true" />}
                          >
                            Edit
                          </Button>
                        ) : null}
                      </Card>
                    ))}
                  </div>
                  <Pagination
                    page={search.page}
                    total={departments.data?.count ?? 0}
                    onPageChange={changePage}
                  />
                </>
              ) : null}
            </>
          ) : (
            <>
              {units.isError && !units.data ? (
                <SectionErrorState error={units.error} onRetry={() => void units.refetch()} />
              ) : null}
              {units.isError && units.data ? (
                <SectionErrorState
                  error={units.error}
                  onRetry={() => void units.refetch()}
                  className="py-2"
                />
              ) : null}
              {!canListDepartments ? (
                <Alert tone="info" role="status">
                  Department names are hidden because this account does not have department list
                  access.
                </Alert>
              ) : null}
              {units.isPending ? (
                <div className="space-y-3">
                  <Skeleton className="h-16 w-full" />
                  <Skeleton className="h-16 w-full" />
                </div>
              ) : null}
              {units.data && unitItems.length === 0 && units.data.count === 0 ? (
                <EmptyState
                  title="No units found"
                  description="Try another filter, or add a unit to an existing department."
                  icon={<Layers3 className="size-6" />}
                />
              ) : null}
              {units.data && unitItems.length === 0 && units.data.count > 0 ? (
                <EmptyState
                  title="This page is outside the available results"
                  description={`${units.data.count} units are available. Return to page ${Math.max(1, Math.ceil(units.data.count / PAGE_SIZE))} to see them.`}
                  action={
                    <Button
                      variant="outline"
                      onClick={() =>
                        changePage(Math.max(1, Math.ceil(units.data!.count / PAGE_SIZE)))
                      }
                    >
                      Go to available page
                    </Button>
                  }
                  icon={<Layers3 className="size-6" />}
                />
              ) : null}
              {unitItems.length ? (
                <>
                  <div className="rounded-control border-border-subtle tablet:block hidden overflow-hidden border">
                    <table className="w-full text-left">
                      <thead className="bg-surface-muted text-caption text-text-secondary">
                        <tr>
                          <th className="px-4 py-3 font-semibold">Unit</th>
                          <th className="px-4 py-3 font-semibold">Department</th>
                          <th className="px-4 py-3 font-semibold">Description</th>
                          <th className="px-4 py-3 text-right font-semibold">Action</th>
                        </tr>
                      </thead>
                      <tbody>
                        {unitItems.map((unit) => (
                          <tr key={unit.id} className="border-border-subtle border-t">
                            <td className="text-body-sm px-4 py-3 font-semibold">{unit.name}</td>
                            <td className="text-body-sm text-text-secondary px-4 py-3">
                              {canListDepartments
                                ? departmentCategoryLabel(unit.department_name)
                                : 'Restricted'}
                            </td>
                            <td className="text-body-sm text-text-secondary px-4 py-3">
                              {unit.description || '—'}
                            </td>
                            <td className="px-4 py-2 text-right">
                              {canUpdateUnit && canListDepartments ? (
                                <Button
                                  variant="ghost"
                                  size="sm"
                                  aria-label={`Edit ${unit.name}`}
                                  disabled={!canListDepartments}
                                  onClick={() => setEditor({ kind: 'unit', value: unit })}
                                  leadingIcon={<Pencil className="size-3.5" aria-hidden="true" />}
                                >
                                  Edit
                                </Button>
                              ) : null}
                            </td>
                          </tr>
                        ))}
                      </tbody>
                    </table>
                  </div>
                  <div className="tablet:hidden space-y-3">
                    {unitItems.map((unit) => (
                      <Card
                        key={unit.id}
                        className="phone:p-4 grid min-w-0 grid-cols-[auto_minmax(0,1fr)_auto] items-start gap-3 p-3"
                      >
                        <span className="bg-info-subtle/70 text-info rounded-control mt-0.5 flex size-9 shrink-0 items-center justify-center">
                          <Layers3 className="size-[18px]" aria-hidden="true" />
                        </span>
                        <div className="min-w-0">
                          <h3 className="text-body-sm text-text-primary font-semibold break-words">
                            {unit.name}
                          </h3>
                          <p className="text-caption text-text-secondary mt-1">
                            {canListDepartments ? (
                              <>
                                <span className="text-text-muted">Department</span>
                                <span aria-hidden="true" className="text-text-muted mx-1.5">
                                  ·
                                </span>
                                {departmentCategoryLabel(unit.department_name)}
                              </>
                            ) : (
                              'Department restricted'
                            )}
                          </p>
                          <Description value={unit.description} />
                        </div>
                        {canUpdateUnit && canListDepartments ? (
                          <Button
                            variant="outline"
                            size="sm"
                            disabled={!canListDepartments}
                            aria-label={`Edit ${unit.name}`}
                            onClick={() => setEditor({ kind: 'unit', value: unit })}
                            leadingIcon={<Pencil className="size-3.5" aria-hidden="true" />}
                          >
                            Edit
                          </Button>
                        ) : null}
                      </Card>
                    ))}
                  </div>
                  <Pagination
                    page={search.page}
                    total={units.data?.count ?? 0}
                    onPageChange={changePage}
                  />
                </>
              ) : null}
            </>
          )}
        </Card>
      </div>

      {editor?.kind === 'department' ? (
        <DepartmentEditor
          value={editor.value}
          usedNames={usedNames}
          userId={userId}
          employeeId={employeeId}
          isSaving={createDepartment.isPending || updateDepartment.isPending}
          onClose={() => setEditor(null)}
          onSave={(input) =>
            editor.value
              ? updateDepartment.mutateAsync({ id: editor.value.id, input })
              : createDepartment.mutateAsync(input)
          }
        />
      ) : null}
      {editor?.kind === 'unit' ? (
        <UnitEditor
          value={editor.value}
          departments={allDepartments.data?.items ?? []}
          departmentsLoading={allDepartments.isPending && !allDepartments.data}
          departmentsError={allDepartments.error}
          onRetryDepartments={() => void allDepartments.refetch()}
          isSaving={createUnit.isPending || updateUnit.isPending}
          onClose={() => setEditor(null)}
          onSave={(input) =>
            editor.value
              ? updateUnit.mutateAsync({ id: editor.value.id, input })
              : createUnit.mutateAsync(input)
          }
        />
      ) : null}
    </PageLayout>
  )
}
