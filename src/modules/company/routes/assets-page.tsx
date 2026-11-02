import { keepPreviousData, useMutation, useQuery, useQueryClient } from '@tanstack/react-query'
import { useNavigate, useSearch } from '@tanstack/react-router'
import {
  ChevronLeft,
  ChevronRight,
  Eye,
  FilePlus2,
  MapPin,
  MoreHorizontal,
  Package2,
  Pencil,
  Search,
  Trash2,
  UserRound,
} from 'lucide-react'
import {
  useCallback,
  useEffect,
  useId,
  useMemo,
  useRef,
  useState,
  type CSSProperties,
  type KeyboardEvent,
} from 'react'
import { createPortal } from 'react-dom'

import {
  assetQueryKeys,
  assetsApi,
  type AssetDto,
  type AssetListParams,
  type AssetWriteInput,
} from '@/modules/company/assets.api'
import { companyOverviewQueryKey } from '@/modules/company/company-dashboard.api'
import { AssetDetailDialog } from '@/modules/company/routes/asset-detail-dialog'
import { AssetFormDialog } from '@/modules/company/routes/asset-form-dialog'
import { authSessionQueryOptions, hasPermission } from '@/shared/auth/session'
import { useToast } from '@/shared/feedback/use-toast'
import { presentError } from '@/shared/errors'
import { DATA_FRESHNESS_MS } from '@/shared/query/freshness'
import { Alert } from '@/shared/ui/alert'
import { Button } from '@/shared/ui/button'
import { Card } from '@/shared/ui/card'
import { Dialog } from '@/shared/ui/dialog'
import { EmptyState, ErrorState, SectionErrorState, Skeleton } from '@/shared/ui/feedback-states'
import { TextInput } from '@/shared/ui/form-control'
import { PageLayout } from '@/shared/ui/page-layout'
import { StatusChip, type StatusTone } from '@/shared/ui/status-chip'
import type { AssetsSearch } from '@/modules/company/assets.search'

const PAGE_SIZE = 10

const assetTypeLabels: Record<string, string> = {
  laptop: 'Laptop',
  printer: 'Printer',
  vehicle: 'Vehicle',
  furniture: 'Furniture',
  equipment: 'Equipment',
  other: 'Other',
}

function assetTypeLabel(value: string) {
  return assetTypeLabels[value] ?? value.replaceAll('_', ' ')
}

function statusLabel(status: string) {
  const labels: Record<string, string> = {
    available: 'Available',
    in_use: 'In use',
    'in-use': 'In use',
    active: 'Available',
    maintenance: 'Maintenance',
    retired: 'Retired',
    lost_stolen: 'Lost or stolen',
  }
  return labels[status] ?? status.replaceAll('_', ' ')
}

function statusTone(status: string): StatusTone {
  if (status === 'available' || status === 'active') return 'success'
  if (status === 'in_use' || status === 'in-use') return 'primary'
  if (status === 'maintenance') return 'warning'
  if (status === 'lost_stolen') return 'danger'
  return 'neutral'
}

function AssetSearchInput({
  search,
  onCommit,
}: {
  search: string
  onCommit: (value: string) => void
}) {
  const [value, setValue] = useState(search)
  const draft = value.trim()

  useEffect(() => {
    if (draft === search) return
    const timer = window.setTimeout(() => onCommit(draft), 250)
    return () => window.clearTimeout(timer)
  }, [draft, onCommit, search])

  return (
    <div className="space-y-1.5">
      <label
        htmlFor="asset-search"
        className="text-control-label text-text-secondary block font-bold"
      >
        Search assets
      </label>
      <div className="relative">
        <Search
          className="text-text-muted absolute top-1/2 left-3.5 size-4 -translate-y-1/2"
          aria-hidden="true"
        />
        <TextInput
          type="search"
          id="asset-search"
          value={value}
          onChange={(event) => setValue(event.currentTarget.value)}
          placeholder="Name, serial number, branch or invoice"
          className="pl-10"
        />
      </div>
    </div>
  )
}

function getAssetMenuPosition(trigger: HTMLElement, itemCount: number) {
  const rect = trigger.getBoundingClientRect()
  const padding = 8
  const width = Math.min(192, window.innerWidth - padding * 2)
  const height = itemCount * 40 + 12
  const openAbove = window.innerHeight - rect.bottom < height && rect.top > height

  return {
    position: 'fixed' as const,
    top: openAbove ? Math.max(padding, rect.top - height - 4) : rect.bottom + 4,
    left: Math.min(
      Math.max(padding, rect.right - width),
      Math.max(padding, window.innerWidth - width - padding),
    ),
    width,
    zIndex: 250,
  } satisfies CSSProperties
}

function focusAdjacentTo(trigger: HTMLElement, direction: -1 | 1) {
  const focusable = Array.from(
    document.querySelectorAll<HTMLElement>(
      'a[href], button:not([disabled]), input:not([disabled]), select:not([disabled]), textarea:not([disabled]), [tabindex]:not([tabindex="-1"])',
    ),
  ).filter(
    (element) =>
      element.tabIndex >= 0 &&
      !element.closest('[role="menu"]') &&
      !element.closest('[aria-hidden="true"]') &&
      element.getClientRects().length > 0,
  )
  const triggerIndex = focusable.indexOf(trigger)
  focusable[triggerIndex + direction]?.focus()
}

function AssetActions({
  asset,
  canUpdate,
  canDelete,
  onView,
  onEdit,
  onDelete,
}: {
  asset: AssetDto
  canUpdate: boolean
  canDelete: boolean
  onView: (asset: AssetDto) => void
  onEdit: (asset: AssetDto) => void
  onDelete: (asset: AssetDto) => void
}) {
  const triggerRef = useRef<HTMLButtonElement>(null)
  const menuRef = useRef<HTMLDivElement>(null)
  const itemRefs = useRef<Array<HTMLElement | null>>([])
  const menuId = useId()
  const [open, setOpen] = useState(false)
  const [position, setPosition] = useState<CSSProperties | null>(null)
  const itemCount = 1 + Number(canUpdate) + Number(canDelete)

  const closeMenu = useCallback((restoreFocus = false) => {
    setOpen(false)
    setPosition(null)
    if (restoreFocus) requestAnimationFrame(() => triggerRef.current?.focus())
  }, [])

  const openMenu = (last = false) => {
    const trigger = triggerRef.current
    if (!trigger) return
    setPosition(getAssetMenuPosition(trigger, itemCount))
    setOpen(true)
    requestAnimationFrame(() => {
      const items = itemRefs.current.filter((item): item is HTMLElement => item !== null)
      items[last ? items.length - 1 : 0]?.focus()
    })
  }

  useEffect(() => {
    if (!open) return

    const closeOnOutsidePointer = (event: PointerEvent) => {
      const target = event.target as Node
      if (triggerRef.current?.contains(target) || menuRef.current?.contains(target)) return
      closeMenu()
    }
    const reposition = () => {
      const trigger = triggerRef.current
      if (!trigger?.isConnected) {
        closeMenu()
        return
      }
      setPosition(getAssetMenuPosition(trigger, itemCount))
    }

    document.addEventListener('pointerdown', closeOnOutsidePointer, true)
    window.addEventListener('resize', reposition)
    window.addEventListener('scroll', reposition, true)
    return () => {
      document.removeEventListener('pointerdown', closeOnOutsidePointer, true)
      window.removeEventListener('resize', reposition)
      window.removeEventListener('scroll', reposition, true)
    }
  }, [closeMenu, itemCount, open])

  const handleMenuKeyDown = (event: KeyboardEvent<HTMLDivElement>) => {
    const items = itemRefs.current.filter((item): item is HTMLElement => item !== null)
    const index = items.indexOf(document.activeElement as HTMLElement)
    if (event.key === 'Escape') {
      event.preventDefault()
      closeMenu(true)
    } else if (event.key === 'ArrowDown' || event.key === 'ArrowUp') {
      event.preventDefault()
      const direction = event.key === 'ArrowDown' ? 1 : -1
      const next = index < 0 ? 0 : (index + direction + items.length) % items.length
      items[next]?.focus()
    } else if (event.key === 'Home' || event.key === 'End') {
      event.preventDefault()
      items[event.key === 'Home' ? 0 : items.length - 1]?.focus()
    } else if (event.key === 'Tab') {
      event.preventDefault()
      const direction = event.shiftKey ? -1 : 1
      closeMenu()
      requestAnimationFrame(() => {
        if (triggerRef.current) focusAdjacentTo(triggerRef.current, direction)
      })
    }
  }

  const select = (action: () => void) => {
    closeMenu()
    action()
  }

  return (
    <>
      <button
        ref={triggerRef}
        type="button"
        aria-label={`Actions for ${asset.name}`}
        aria-haspopup="menu"
        aria-expanded={open}
        aria-controls={menuId}
        onClick={() => (open ? closeMenu() : openMenu())}
        onKeyDown={(event) => {
          if (event.key === 'ArrowDown' || event.key === 'ArrowUp') {
            event.preventDefault()
            openMenu(event.key === 'ArrowUp')
          }
        }}
        className="rounded-control focus-visible:shadow-focus-ring text-text-secondary hover:bg-surface-muted hover:text-text-primary inline-flex size-10 shrink-0 items-center justify-center border border-transparent transition-colors focus-visible:outline-none"
      >
        <MoreHorizontal className="size-5" aria-hidden="true" />
      </button>
      {open && position
        ? createPortal(
            <div
              ref={menuRef}
              id={menuId}
              role="menu"
              aria-label={`Actions for ${asset.name}`}
              onKeyDown={handleMenuKeyDown}
              style={position}
              className="border-border-subtle bg-surface rounded-control shadow-overlay overflow-hidden border p-1.5"
            >
              <button
                ref={(element) => {
                  itemRefs.current[0] = element
                }}
                type="button"
                role="menuitem"
                tabIndex={-1}
                onClick={() => select(() => onView(asset))}
                className="rounded-control text-body-sm text-text-primary hover:bg-surface-muted focus-visible:bg-surface-muted flex min-h-10 w-full items-center gap-2.5 px-3 text-left font-medium focus-visible:outline-none"
              >
                <Eye className="text-text-secondary size-4 shrink-0" aria-hidden="true" />
                View details
              </button>
              {canUpdate ? (
                <button
                  ref={(element) => {
                    itemRefs.current[1] = element
                  }}
                  type="button"
                  role="menuitem"
                  tabIndex={-1}
                  onClick={() => select(() => onEdit(asset))}
                  className="rounded-control text-body-sm text-text-primary hover:bg-surface-muted focus-visible:bg-surface-muted flex min-h-10 w-full items-center gap-2.5 px-3 text-left font-medium focus-visible:outline-none"
                >
                  <Pencil className="text-text-secondary size-4 shrink-0" aria-hidden="true" />
                  Edit asset
                </button>
              ) : null}
              {canDelete ? (
                <button
                  ref={(element) => {
                    itemRefs.current[Number(canUpdate) + 1] = element
                  }}
                  type="button"
                  role="menuitem"
                  tabIndex={-1}
                  onClick={() => select(() => onDelete(asset))}
                  className="rounded-control text-body-sm text-danger hover:bg-danger-subtle focus-visible:bg-danger-subtle flex min-h-10 w-full items-center gap-2.5 px-3 text-left font-medium focus-visible:outline-none"
                >
                  <Trash2 className="size-4 shrink-0" aria-hidden="true" />
                  Delete asset
                </button>
              ) : null}
            </div>,
            document.body,
          )
        : null}
    </>
  )
}

function AssetRegisterRow({
  asset,
  canUpdate,
  canDelete,
  onView,
  onEdit,
  onDelete,
}: {
  asset: AssetDto
  canUpdate: boolean
  canDelete: boolean
  onView: (asset: AssetDto) => void
  onEdit: (asset: AssetDto) => void
  onDelete: (asset: AssetDto) => void
}) {
  return (
    <tr className="border-border-subtle border-t align-top">
      <td className="px-4 py-4">
        <div className="flex min-w-48 items-start gap-3">
          <span className="bg-primary-subtle text-primary rounded-control flex size-9 shrink-0 items-center justify-center">
            <Package2 className="size-4" aria-hidden="true" />
          </span>
          <div className="min-w-0">
            <button
              type="button"
              className="text-body-sm text-text-primary hover:text-primary focus-visible:outline-primary text-left font-semibold focus-visible:outline focus-visible:outline-2"
              onClick={() => onView(asset)}
            >
              {asset.name}
            </button>
            <p className="text-caption text-text-secondary mt-1">
              {asset.serial_number || 'No serial number'}
            </p>
          </div>
        </div>
      </td>
      <td className="text-body-sm text-text-primary px-4 py-4">
        {assetTypeLabel(asset.asset_type)}
      </td>
      <td className="text-body-sm text-text-primary px-4 py-4">{asset.branch || 'Not recorded'}</td>
      <td className="text-body-sm text-text-secondary px-4 py-4">
        {asset.assigned_to_id == null ? 'Unassigned' : 'Employee ' + asset.assigned_to_id}
      </td>
      <td className="px-4 py-4">
        <StatusChip label={statusLabel(asset.status)} tone={statusTone(asset.status)} dense />
      </td>
      <td className="px-4 py-3">
        <AssetActions
          asset={asset}
          canUpdate={canUpdate}
          canDelete={canDelete}
          onView={onView}
          onEdit={onEdit}
          onDelete={onDelete}
        />
      </td>
    </tr>
  )
}

function AssetRegisterCard({
  asset,
  canUpdate,
  canDelete,
  onView,
  onEdit,
  onDelete,
}: {
  asset: AssetDto
  canUpdate: boolean
  canDelete: boolean
  onView: (asset: AssetDto) => void
  onEdit: (asset: AssetDto) => void
  onDelete: (asset: AssetDto) => void
}) {
  return (
    <article className="border-border-subtle bg-surface rounded-surface shadow-elevation-sm tablet:p-5 min-w-0 border p-4">
      <div className="flex min-w-0 items-start gap-3">
        <span className="bg-primary-subtle text-primary rounded-control flex size-11 shrink-0 items-center justify-center">
          <Package2 className="size-5" aria-hidden="true" />
        </span>
        <div className="min-w-0 flex-1">
          <div className="flex min-w-0 items-start justify-between gap-2">
            <div className="min-w-0">
              <h2 className="text-body-md text-text-primary font-semibold break-words">
                <button
                  type="button"
                  className="hover:text-primary focus-visible:shadow-focus-ring text-left focus-visible:outline-none"
                  onClick={() => onView(asset)}
                >
                  {asset.name}
                </button>
              </h2>
              <p className="text-caption text-text-secondary mt-1">
                {assetTypeLabel(asset.asset_type)}
                {asset.serial_number ? ' · ' + asset.serial_number : ' · No serial number'}
              </p>
            </div>
            <AssetActions
              asset={asset}
              canUpdate={canUpdate}
              canDelete={canDelete}
              onView={onView}
              onEdit={onEdit}
              onDelete={onDelete}
            />
          </div>
          <div className="mt-2">
            <StatusChip label={statusLabel(asset.status)} tone={statusTone(asset.status)} dense />
          </div>
        </div>
      </div>
      <div className="border-border-subtle mt-4 grid grid-cols-1 gap-3 border-t pt-3 min-[480px]:grid-cols-2">
        <div className="flex min-w-0 items-start gap-2.5">
          <MapPin className="text-text-muted mt-0.5 size-4 shrink-0" aria-hidden="true" />
          <div className="min-w-0">
            <p className="text-overline text-text-secondary">Branch</p>
            <p className="text-body-sm text-text-primary mt-0.5 break-words">
              {asset.branch || 'Not recorded'}
            </p>
          </div>
        </div>
        <div className="flex min-w-0 items-start gap-2.5">
          <UserRound className="text-text-muted mt-0.5 size-4 shrink-0" aria-hidden="true" />
          <div className="min-w-0">
            <p className="text-overline text-text-secondary">Assigned to</p>
            <p className="text-body-sm text-text-primary mt-0.5 break-words">
              {asset.assigned_to_id == null ? 'Unassigned' : 'Employee ' + asset.assigned_to_id}
            </p>
          </div>
        </div>
      </div>
    </article>
  )
}

function AssetListSkeleton() {
  return (
    <div className="space-y-3" aria-label="Loading assets" role="status">
      {Array.from({ length: 5 }, (_, index) => (
        <Card key={index} className="flex items-center gap-4 p-4">
          <Skeleton className="rounded-control size-10" />
          <div className="min-w-0 flex-1 space-y-2">
            <Skeleton className="h-4 w-48 max-w-full" />
            <Skeleton className="h-3 w-64 max-w-full" />
          </div>
          <Skeleton className="h-7 w-24" />
        </Card>
      ))}
    </div>
  )
}

export function AssetsPage() {
  const search = useSearch({ from: '/_protected/company/assets' }) as AssetsSearch
  const navigate = useNavigate({ from: '/_protected/company/assets' })
  const queryClient = useQueryClient()
  const { showToast } = useToast()
  const sessionQuery = useQuery(authSessionQueryOptions())
  const session = sessionQuery.data
  const userId = session?.user.id ?? 0
  const employeeId = session?.employee.employee_id ?? ''
  const permissions = session?.permissions ?? {}
  const canCreate = hasPermission(permissions, 'assets', 'create')
  const canUpdate = hasPermission(permissions, 'assets', 'update')
  const canDelete = hasPermission(permissions, 'assets', 'delete')
  const [viewingAsset, setViewingAsset] = useState<AssetDto | null>(null)
  const [editingAsset, setEditingAsset] = useState<AssetDto | null>(null)
  const [formOpen, setFormOpen] = useState(false)
  const [deleteTarget, setDeleteTarget] = useState<AssetDto | null>(null)

  const commitSearch = useCallback(
    (value: string) => {
      void navigate({
        to: '/company/assets',
        search: (previous: AssetsSearch) => ({ ...previous, search: value, page: 1 }),
        replace: true,
      })
    },
    [navigate],
  )
  const params: AssetListParams = useMemo(
    () => ({
      limit: PAGE_SIZE,
      offset: (search.page - 1) * PAGE_SIZE,
      search: search.search,
    }),
    [search.page, search.search],
  )
  const listQuery = useQuery({
    queryKey: assetQueryKeys.list(userId, employeeId, params),
    queryFn: ({ signal }) => assetsApi.list(params, signal),
    enabled: Boolean(session && hasPermission(permissions, 'assets', 'list')),
    staleTime: DATA_FRESHNESS_MS.standard,
    refetchOnWindowFocus: true,
    refetchOnReconnect: true,
    placeholderData: keepPreviousData,
  })

  async function invalidateAssetData() {
    await Promise.all([
      queryClient.invalidateQueries({ queryKey: assetQueryKeys.lists(userId, employeeId) }),
      queryClient.invalidateQueries({
        queryKey: companyOverviewQueryKey(userId, employeeId),
      }),
    ])
  }

  const createMutation = useMutation({
    mutationFn: (input: AssetWriteInput) => assetsApi.create(input),
    onSuccess: async () => {
      await invalidateAssetData()
      setFormOpen(false)
      showToast({
        title: 'Asset created',
        description: 'The new asset has been added to the company register.',
        tone: 'success',
      })
    },
  })
  const updateMutation = useMutation({
    mutationFn: ({ id, input }: { id: number; input: AssetWriteInput }) =>
      assetsApi.update(id, input),
    onSuccess: async () => {
      await invalidateAssetData()
      setFormOpen(false)
      setEditingAsset(null)
      showToast({
        title: 'Asset updated',
        description: 'Your changes have been saved to the company register.',
        tone: 'success',
      })
    },
  })
  const deleteMutation = useMutation({
    mutationFn: (id: number) => assetsApi.remove(id),
    onSuccess: async () => {
      await invalidateAssetData()
      setDeleteTarget(null)
      showToast({
        title: 'Asset deleted',
        description: 'The asset was removed from the company register.',
        tone: 'success',
      })
    },
    onError: (error) =>
      showToast({
        title: 'Asset could not be deleted',
        description: presentError(error, 'background-action').message,
        tone: 'danger',
      }),
  })

  function openCreate() {
    setEditingAsset(null)
    setFormOpen(true)
  }

  function openEdit(asset: AssetDto) {
    setEditingAsset(asset)
    setFormOpen(true)
  }

  async function saveAsset(input: AssetWriteInput, assetId: number | null) {
    if (assetId == null) {
      await createMutation.mutateAsync(input)
    } else {
      await updateMutation.mutateAsync({ id: assetId, input })
    }
  }

  const pageCount = Math.max(1, Math.ceil((listQuery.data?.count ?? 0) / PAGE_SIZE))
  const total = listQuery.data?.count ?? 0
  const firstItem = total ? params.offset + 1 : 0
  const lastItem = Math.min(params.offset + PAGE_SIZE, total)

  return (
    <PageLayout
      title="Company Assets"
      subtitle="Manage company-owned assets across your branches."
      actionsInline
      actions={
        canCreate ? (
          <Button
            aria-label="New asset"
            onClick={openCreate}
            leadingIcon={<FilePlus2 className="size-4" aria-hidden="true" />}
            className="max-[479px]:text-caption max-[479px]:min-h-9 max-[479px]:px-3"
          >
            <span className="max-[479px]:hidden">New asset</span>
            <span className="hidden max-[479px]:inline max-[361px]:hidden">New</span>
          </Button>
        ) : null
      }
    >
      <div className="space-y-4">
        <Card className="p-4">
          <div className="flex flex-wrap items-end justify-between gap-4">
            <div className="w-full max-w-2xl">
              <AssetSearchInput search={search.search} onCommit={commitSearch} />
            </div>
            {listQuery.data ? (
              <span className="border-border-subtle bg-surface-muted text-caption text-text-secondary inline-flex min-h-8 items-center gap-1.5 rounded-full border px-3 font-medium">
                <Package2 className="size-3.5" aria-hidden="true" />
                {total} {total === 1 ? 'asset' : 'assets'} in scope
              </span>
            ) : null}
          </div>
        </Card>

        {listQuery.isError && listQuery.data ? (
          <SectionErrorState
            title="The register could not refresh"
            description="Showing the last loaded results. Retry when your connection is available."
            error={listQuery.error}
            onRetry={() => void listQuery.refetch()}
          />
        ) : null}

        {listQuery.isLoading ? (
          <AssetListSkeleton />
        ) : listQuery.isError && !listQuery.data ? (
          <Card className="p-3">
            <ErrorState
              title="Assets could not be loaded"
              description={presentError(listQuery.error, 'page-load').message}
              action={
                <Button variant="outline" onClick={() => void listQuery.refetch()}>
                  Try again
                </Button>
              }
            />
          </Card>
        ) : listQuery.data?.items.length ? (
          <>
            <Card className="desktop:block hidden overflow-hidden p-0">
              <div className="overflow-x-auto">
                <table className="text-body-sm w-full min-w-[760px] border-collapse text-left">
                  <thead className="bg-surface-muted/65 text-overline text-text-secondary">
                    <tr>
                      <th scope="col" className="px-4 py-3 text-left font-semibold">
                        Asset
                      </th>
                      <th scope="col" className="px-4 py-3 font-semibold">
                        Type
                      </th>
                      <th scope="col" className="px-4 py-3 font-semibold">
                        Branch
                      </th>
                      <th scope="col" className="px-4 py-3 font-semibold">
                        Assigned to
                      </th>
                      <th scope="col" className="px-4 py-3 font-semibold">
                        Status
                      </th>
                      <th scope="col" className="px-4 py-3 font-semibold">
                        Actions
                      </th>
                    </tr>
                  </thead>
                  <tbody>
                    {listQuery.data.items.map((asset) => (
                      <AssetRegisterRow
                        key={asset.id}
                        asset={asset}
                        canUpdate={canUpdate}
                        canDelete={canDelete}
                        onView={setViewingAsset}
                        onEdit={openEdit}
                        onDelete={setDeleteTarget}
                      />
                    ))}
                  </tbody>
                </table>
              </div>
            </Card>
            <div className="desktop:hidden space-y-3">
              {listQuery.data.items.map((asset) => (
                <AssetRegisterCard
                  key={asset.id}
                  asset={asset}
                  canUpdate={canUpdate}
                  canDelete={canDelete}
                  onView={setViewingAsset}
                  onEdit={openEdit}
                  onDelete={setDeleteTarget}
                />
              ))}
            </div>
            <Card className="flex flex-wrap items-center justify-between gap-3 p-3">
              <p className="text-caption text-text-secondary" aria-live="polite">
                Showing {firstItem}-{lastItem} of {total}
              </p>
              <div className="flex items-center gap-2">
                <Button
                  variant="outline"
                  size="sm"
                  disabled={search.page <= 1 || listQuery.isPlaceholderData}
                  leadingIcon={<ChevronLeft className="size-4" aria-hidden="true" />}
                  onClick={() =>
                    void navigate({
                      to: '/company/assets',
                      search: (previous: AssetsSearch) => ({ ...previous, page: search.page - 1 }),
                    })
                  }
                >
                  Previous
                </Button>
                <span className="text-caption text-text-secondary px-1">
                  Page {search.page} of {pageCount}
                </span>
                <Button
                  variant="outline"
                  size="sm"
                  disabled={search.page >= pageCount || listQuery.isPlaceholderData}
                  onClick={() =>
                    void navigate({
                      to: '/company/assets',
                      search: (previous: AssetsSearch) => ({ ...previous, page: search.page + 1 }),
                    })
                  }
                >
                  Next <ChevronRight className="size-4" aria-hidden="true" />
                </Button>
              </div>
            </Card>
          </>
        ) : (
          <Card className="p-2">
            <EmptyState
              title={search.search ? 'No matching assets' : 'No assets in this register'}
              description={
                search.search
                  ? 'Try a different name, serial number, branch or invoice number.'
                  : 'Company assets will appear here when they are added to your accessible branches.'
              }
              icon={<Package2 className="size-6" aria-hidden="true" />}
              action={
                canCreate && !search.search ? (
                  <Button
                    onClick={openCreate}
                    leadingIcon={<FilePlus2 className="size-4" aria-hidden="true" />}
                  >
                    Add the first asset
                  </Button>
                ) : undefined
              }
            />
          </Card>
        )}
      </div>

      {formOpen ? (
        <AssetFormDialog
          key={editingAsset?.id ?? 'new-asset'}
          open={formOpen}
          onOpenChange={(open) => {
            setFormOpen(open)
            if (!open) setEditingAsset(null)
          }}
          asset={editingAsset}
          userId={userId}
          employeeId={employeeId}
          onSave={saveAsset}
        />
      ) : null}
      <AssetDetailDialog
        asset={viewingAsset}
        open={Boolean(viewingAsset)}
        onOpenChange={(open) => {
          if (!open) setViewingAsset(null)
        }}
      />
      <Dialog
        open={Boolean(deleteTarget)}
        onOpenChange={(open) => {
          if (!open && !deleteMutation.isPending) setDeleteTarget(null)
        }}
        title="Delete asset?"
        description={
          deleteTarget
            ? 'This will permanently remove ' + deleteTarget.name + ' from the register.'
            : undefined
        }
        size="sm"
        fitContent
        compactOnMobile
        dismissDisabled={deleteMutation.isPending}
        footer={
          <div className="flex justify-end gap-2">
            <Button
              variant="outline"
              onClick={() => setDeleteTarget(null)}
              disabled={deleteMutation.isPending}
            >
              Cancel
            </Button>
            <Button
              variant="danger"
              isLoading={deleteMutation.isPending}
              onClick={() => {
                if (deleteTarget) void deleteMutation.mutate(deleteTarget.id)
              }}
            >
              Delete asset
            </Button>
          </div>
        }
      >
        <Alert tone="warning" role="status">
          This action cannot be undone.
        </Alert>
      </Dialog>
    </PageLayout>
  )
}
