import { keepPreviousData, useQuery } from '@tanstack/react-query'
import { useNavigate, useSearch } from '@tanstack/react-router'
import {
  CalendarDays,
  ChevronLeft,
  ChevronRight,
  CircleDollarSign,
  Clock3,
  Search,
  WalletCards,
} from 'lucide-react'
import { useState, type FormEvent } from 'react'

import { authSessionQueryOptions, hasPermission } from '@/shared/auth/session'
import { Button } from '@/shared/ui/button'
import { Card } from '@/shared/ui/card'
import { Dialog } from '@/shared/ui/dialog'
import { DropdownSelect } from '@/shared/ui/dropdown-select'
import { EmptyState, ErrorState, SectionErrorState, Skeleton } from '@/shared/ui/feedback-states'
import { FormControl, TextInput } from '@/shared/ui/form-control'
import { PageLayout } from '@/shared/ui/page-layout'
import { StatusChip, type StatusTone } from '@/shared/ui/status-chip'

import { benefitsListOptions } from '../benefits.queries'
import type { PayrollAllowanceRecord, PayrollStatus } from '../benefits.api'
import type { BenefitsSearch } from '../benefits.search'
import type { MyPaySearch } from '../my-pay.search'

const STATUS_OPTIONS = [
  { value: 'all', label: 'All statuses' },
  { value: 'pending', label: 'Pending' },
  { value: 'approved', label: 'Approved' },
  { value: 'paid', label: 'Paid' },
  { value: 'cancelled', label: 'Cancelled' },
]

const PAGE_SIZE_OPTIONS = [10, 20, 50].map((size) => ({
  value: String(size),
  label: `${size} per page`,
}))

function formatMoney(value: number | null): string {
  if (value == null) return '—'
  const amount = new Intl.NumberFormat('en-NG', { maximumFractionDigits: 2 }).format(value)
  return `₦${amount}`
}

function formatDate(value: string | null): string {
  if (!value) return 'Not paid yet'
  const [year, month, day] = value.slice(0, 10).split('-').map(Number)
  if (!year || !month || !day) return value
  return new Intl.DateTimeFormat(undefined, {
    day: 'numeric',
    month: 'short',
    year: 'numeric',
  }).format(new Date(year, month - 1, day))
}

function payrollStatusLabel(status: PayrollStatus): string {
  return status.charAt(0).toUpperCase() + status.slice(1)
}

function payrollStatusTone(status: PayrollStatus): StatusTone {
  if (status === 'paid' || status === 'approved') return 'success'
  if (status === 'pending' || status === 'processing') return 'warning'
  if (status === 'cancelled' || status === 'failed') return 'danger'
  return 'neutral'
}

function formatAllowanceName(value: string): string {
  return value
    .replace(/[_-]+/g, ' ')
    .trim()
    .replace(/\b\w/g, (letter) => letter.toUpperCase())
}

function disbursementLabel(record: PayrollAllowanceRecord): string {
  if (record.disbursementDate) return formatDate(record.disbursementDate)
  if (record.status === 'cancelled') return 'Not disbursed'
  if (record.status === 'pending' || record.status === 'approved') return 'Awaiting payment'
  return 'Date not recorded'
}

function AllowanceCard({
  record,
  onOpen,
  personal = false,
}: {
  record: PayrollAllowanceRecord
  onOpen: () => void
  personal?: boolean
}) {
  return (
    <article className="border-border-subtle bg-surface shadow-elevation-sm rounded-surface min-w-0 overflow-hidden border">
      <header className="tablet:p-5 flex min-w-0 items-start gap-3 p-4">
        <span className="bg-primary-subtle text-primary flex size-11 shrink-0 items-center justify-center rounded-xl">
          <WalletCards className="size-5" aria-hidden="true" />
        </span>
        <div className="flex min-w-0 flex-1 items-start gap-2">
          <div className="min-w-0 flex-1">
            <h3 className="text-body-lg text-text-primary line-clamp-2 font-semibold break-words">
              {personal ? record.period : record.employeeName}
            </h3>
            <p className="text-caption text-text-secondary mt-0.5 break-words">
              {personal ? 'Payslip' : `${record.employeeCode} · ${record.designation}`}
            </p>
          </div>
          <StatusChip
            label={payrollStatusLabel(record.status)}
            tone={payrollStatusTone(record.status)}
            dense
          />
        </div>
      </header>

      <div className="bg-surface-muted/65 border-border-subtle phone:grid-cols-3 tablet:px-5 grid min-w-0 grid-cols-2 gap-x-4 gap-y-3 border-y px-4 py-3">
        <MoneyMetric label="Gross pay" value={formatMoney(record.baseSalary)} />
        <MoneyMetric label="Allowances" value={formatMoney(record.allowanceTotal)} />
        <MoneyMetric
          label="Net pay"
          value={formatMoney(record.netPay)}
          className="phone:col-span-1 col-span-2"
          emphasized
        />
      </div>

      <footer className="tablet:px-5 flex min-w-0 flex-wrap items-center justify-between gap-2 px-4 py-3">
        <div className="text-caption text-text-secondary flex min-w-0 flex-wrap items-center gap-x-4 gap-y-1">
          <span className="inline-flex items-center gap-1.5">
            <CalendarDays className="size-4 shrink-0" aria-hidden="true" />
            {record.period}
          </span>
          <span className="inline-flex items-center gap-1.5">
            <Clock3 className="size-4 shrink-0" aria-hidden="true" />
            {disbursementLabel(record)}
          </span>
        </div>
        <Button variant="ghost" size="sm" onClick={onOpen} className="ml-auto shrink-0">
          View payroll details
          <ChevronRight className="size-4" aria-hidden="true" />
        </Button>
      </footer>
    </article>
  )
}

function MoneyMetric({
  label,
  value,
  className,
  emphasized = false,
}: {
  label: string
  value: string
  className?: string
  emphasized?: boolean
}) {
  return (
    <div className={className}>
      <p className="text-overline text-text-secondary">{label}</p>
      <p
        className={`text-body-sm mt-0.5 font-semibold tabular-nums ${emphasized ? 'text-primary' : 'text-text-primary'}`}
      >
        {value}
      </p>
    </div>
  )
}

type PayrollSearch = Pick<BenefitsSearch, 'status' | 'page' | 'pageSize'> & { search?: string }
type PayrollSearchUpdate = Partial<BenefitsSearch>

export function BenefitsPage() {
  const search = useSearch({ from: '/_protected/hr/benefits' }) as BenefitsSearch
  const navigate = useNavigate()
  return (
    <PayrollPageContent
      personal={false}
      search={search}
      onSearchChange={(updates) =>
        void navigate({
          to: '/hr/benefits',
          search: (previous: BenefitsSearch) => ({ ...previous, ...updates }),
          resetScroll: false,
        })
      }
    />
  )
}

export function MyPayPage() {
  const search = useSearch({ from: '/_protected/dashboard/my-pay' }) as MyPaySearch
  const navigate = useNavigate()
  return (
    <PayrollPageContent
      personal
      search={search}
      onSearchChange={(updates) =>
        void navigate({
          to: '/dashboard/my-pay',
          search: (previous: MyPaySearch) => ({
            ...previous,
            ...(Object.hasOwn(updates, 'status') ? { status: updates.status } : {}),
            ...(Object.hasOwn(updates, 'page') ? { page: updates.page } : {}),
            ...(Object.hasOwn(updates, 'pageSize') ? { pageSize: updates.pageSize } : {}),
          }),
          resetScroll: false,
        })
      }
    />
  )
}

function PayrollPageContent({
  personal,
  search,
  onSearchChange,
}: {
  personal: boolean
  search: PayrollSearch
  onSearchChange: (updates: PayrollSearchUpdate) => void
}) {
  const sessionQuery = useQuery(authSessionQueryOptions())
  const session = sessionQuery.data
  const userId = session?.user.id ?? 0
  const employeeKey = session?.employee.employee_id ?? ''
  const permissions = session?.permissions ?? {}
  const canList = hasPermission(permissions, 'payroll', 'list')
  const canListOwn = hasPermission(permissions, 'payroll', 'list_own')
  const canView = personal ? canList || canListOwn : canList
  const employeeId = session?.employee.id
  const searchValue = personal ? '' : (search.search ?? '')
  const [searchDraftState, setSearchDraftState] = useState({
    routeValue: searchValue,
    value: searchValue,
  })
  const [selectedRecord, setSelectedRecord] = useState<PayrollAllowanceRecord | null>(null)
  const searchDraft =
    searchDraftState.routeValue === searchValue ? searchDraftState.value : searchValue

  const params = {
    search: personal ? '' : searchValue,
    status: search.status,
    employeeId: personal ? employeeId : undefined,
    limit: search.pageSize,
    offset: (search.page - 1) * search.pageSize,
  }
  const listQuery = useQuery({
    ...benefitsListOptions(userId, employeeKey, params),
    enabled: Boolean(session && canView && (!personal || employeeId)),
    placeholderData: keepPreviousData,
  })
  const updateSearch = (updates: PayrollSearchUpdate) => onSearchChange(updates)
  const submitSearch = (event: FormEvent<HTMLFormElement>) => {
    event.preventDefault()
    updateSearch({ search: personal ? undefined : searchDraft.trim(), page: 1 })
  }
  const clearFilters = () => {
    setSearchDraftState({ routeValue: '', value: '' })
    updateSearch({ search: personal ? undefined : '', status: 'all', page: 1 })
  }

  const records = listQuery.data?.items ?? []
  const count = listQuery.data?.count ?? 0
  const pageCount = Math.max(1, Math.ceil(count / search.pageSize))
  const hasActiveFilters = (!personal && Boolean(searchValue)) || search.status !== 'all'

  if (sessionQuery.isError) {
    return (
      <PageLayout title={personal ? 'My Pay' : 'Payroll'}>
        <ErrorState
          title="Your HR session could not be loaded"
          description="Retry loading your account and payroll access."
          error={sessionQuery.error}
        />
      </PageLayout>
    )
  }

  if (session && !canView) {
    return (
      <PageLayout title={personal ? 'My Pay' : 'Payroll'}>
        <ErrorState
          title={personal ? 'You can’t view your pay records' : 'You can’t view payroll records'}
          description="Your account does not have permission to read payroll records."
        />
      </PageLayout>
    )
  }

  if (session && personal && !employeeId) {
    return (
      <PageLayout title="My Pay">
        <ErrorState
          title="Your employee record is unavailable"
          description="Your employee profile could not be matched to payroll records."
        />
      </PageLayout>
    )
  }

  return (
    <PageLayout
      title={personal ? 'My Pay' : 'Payroll'}
      subtitle={
        personal
          ? 'Review your payslips, payment status, and pay breakdown.'
          : 'Review employee payroll records and disbursements.'
      }
      leading={<CircleDollarSign className="size-5" aria-hidden="true" />}
    >
      <div className="space-y-5">
        <Card className="tablet:p-5 space-y-4 p-4">
          <div className="flex flex-wrap items-end justify-between gap-3">
            <div className="min-w-0">
              <p className="text-overline text-primary font-semibold">
                {personal ? 'My Work' : 'HR operations'}
              </p>
              <h2 className="text-h3 text-text-primary mt-1 font-semibold">
                {personal ? 'Pay history' : 'Payroll register'}
              </h2>
              <p className="text-caption text-text-secondary mt-1">
                {personal
                  ? 'Payslips issued to your employee account.'
                  : 'Employee pay, allowances, deductions, and payment status.'}
              </p>
            </div>
            <span
              role="status"
              aria-live="polite"
              className="bg-primary-subtle text-primary text-caption shrink-0 rounded-full px-3 py-1.5 font-semibold tabular-nums"
            >
              {count}{' '}
              {count === 1 ? (personal ? 'payslip' : 'record') : personal ? 'payslips' : 'records'}
            </span>
          </div>
          {personal ? (
            <div className="flex flex-wrap items-end justify-between gap-3">
              <FormControl
                id="my-pay-status"
                label="Payment status"
                className="phone:max-w-80 min-w-0 flex-1"
              >
                <DropdownSelect
                  value={search.status}
                  options={STATUS_OPTIONS}
                  onChange={(status) =>
                    updateSearch({ status: status as BenefitsSearch['status'], page: 1 })
                  }
                  aria-label="Filter payslips by payment status"
                />
              </FormControl>
              {hasActiveFilters ? (
                <Button variant="ghost" size="sm" onClick={clearFilters}>
                  Clear filter
                </Button>
              ) : null}
            </div>
          ) : (
            <form
              onSubmit={submitSearch}
              className="phone:grid-cols-[minmax(0,1fr)_auto] phone:items-end desktop:grid-cols-[minmax(0,1fr)_14rem_auto] desktop:items-end grid min-w-0 gap-3"
            >
              <FormControl id="benefits-search" label="Search payroll records" className="min-w-0">
                <TextInput
                  value={searchDraft}
                  onChange={(event) =>
                    setSearchDraftState({
                      routeValue: searchValue,
                      value: event.currentTarget.value,
                    })
                  }
                  placeholder="Employee name or ID"
                />
              </FormControl>
              <FormControl
                id="benefits-status"
                label="Payroll status"
                className="phone:col-span-2 phone:row-start-2 desktop:col-span-1 desktop:col-start-2 desktop:row-start-1 min-w-0"
              >
                <DropdownSelect
                  value={search.status}
                  options={STATUS_OPTIONS}
                  onChange={(status) =>
                    updateSearch({ status: status as BenefitsSearch['status'], page: 1 })
                  }
                  aria-label="Filter payroll records by status"
                />
              </FormControl>
              <Button
                type="submit"
                variant="primary"
                className="phone:col-start-2 phone:row-start-1 phone:w-auto desktop:col-start-3 desktop:row-start-1 w-full"
                leadingIcon={<Search className="size-4" aria-hidden="true" />}
              >
                Search
              </Button>
            </form>
          )}
          <div className="border-border-subtle flex flex-wrap items-center justify-between gap-2 border-t pt-3">
            <p className="text-caption text-text-muted">
              {personal
                ? 'Only your employee payroll records are shown.'
                : 'Allowance details reflect the selected payroll record.'}
            </p>
            {!personal && hasActiveFilters ? (
              <Button variant="ghost" size="sm" onClick={clearFilters}>
                Clear filters
              </Button>
            ) : null}
          </div>
        </Card>

        {listQuery.isPending ? (
          <div
            className="desktop:grid-cols-2 grid gap-3"
            aria-label={personal ? 'Loading your payslips' : 'Loading payroll'}
          >
            {[0, 1, 2, 3].map((item) => (
              <Skeleton key={item} className="h-52 w-full" />
            ))}
          </div>
        ) : listQuery.isError && !listQuery.data ? (
          <Card>
            <SectionErrorState
              title={
                personal
                  ? 'Your pay records could not be loaded'
                  : 'Payroll records could not be loaded'
              }
              description="Retry the request. Your search and status filter will stay in place."
              onRetry={() => void listQuery.refetch()}
            />
          </Card>
        ) : records.length === 0 ? (
          <Card>
            <EmptyState
              icon={<WalletCards className="size-6" aria-hidden="true" />}
              title={
                searchValue || search.status !== 'all'
                  ? 'No records match these filters'
                  : personal
                    ? 'No payslips yet'
                    : 'No payroll records yet'
              }
              description={
                searchValue || search.status !== 'all'
                  ? personal
                    ? 'Choose another payment status to see your payslips.'
                    : 'Clear the search or choose another status to see payroll records.'
                  : personal
                    ? 'Payslips for your employee account will appear here when available.'
                    : 'Payroll records will appear here when available.'
              }
            />
          </Card>
        ) : (
          <section aria-label="Payroll allowance records" className="space-y-3">
            {listQuery.isError ? (
              <SectionErrorState
                title="Showing saved payroll records"
                description="The latest refresh failed. Retry to update this register."
                onRetry={() => void listQuery.refetch()}
              />
            ) : null}
            <div className="desktop:grid-cols-2 grid min-w-0 gap-3">
              {records.map((record) => (
                <AllowanceCard
                  key={record.id}
                  record={record}
                  personal={personal}
                  onOpen={() => setSelectedRecord(record)}
                />
              ))}
            </div>
            <Card className="flex flex-wrap items-center justify-between gap-3">
              <p className="text-caption text-text-secondary tabular-nums">
                Showing {(search.page - 1) * search.pageSize + 1}–
                {Math.min(search.page * search.pageSize, count)} of {count}
              </p>
              <div className="flex flex-wrap items-center gap-2">
                <DropdownSelect
                  value={String(search.pageSize)}
                  options={PAGE_SIZE_OPTIONS}
                  onChange={(value) =>
                    updateSearch({ pageSize: Number(value) as BenefitsSearch['pageSize'], page: 1 })
                  }
                  aria-label="Payroll records per page"
                  className="min-w-36"
                />
                <Button
                  variant="outline"
                  size="sm"
                  disabled={search.page <= 1}
                  onClick={() => updateSearch({ page: search.page - 1 })}
                >
                  <ChevronLeft className="size-4" aria-hidden="true" /> Previous
                </Button>
                <span className="text-caption text-text-secondary tabular-nums" aria-live="polite">
                  {search.page} / {pageCount}
                </span>
                <Button
                  variant="outline"
                  size="sm"
                  disabled={search.page >= pageCount}
                  onClick={() => updateSearch({ page: search.page + 1 })}
                >
                  Next <ChevronRight className="size-4" aria-hidden="true" />
                </Button>
              </div>
            </Card>
          </section>
        )}
      </div>

      <Dialog
        open={selectedRecord !== null}
        onOpenChange={(open) => {
          if (!open) setSelectedRecord(null)
        }}
        title={
          personal
            ? (selectedRecord?.period ?? 'Payslip details')
            : (selectedRecord?.employeeName ?? 'Payroll details')
        }
        description={
          selectedRecord
            ? personal
              ? 'Your payroll record'
              : `${selectedRecord.employeeCode} · ${selectedRecord.period}`
            : undefined
        }
        size="md"
        fitContent
        compactOnMobile
        footer={
          <Button variant="outline" onClick={() => setSelectedRecord(null)}>
            Close
          </Button>
        }
      >
        {selectedRecord ? (
          <div className="space-y-4">
            <div className="flex flex-wrap items-center justify-between gap-2">
              {personal ? (
                <p className="text-body-sm text-text-secondary">Payslip details</p>
              ) : (
                <p className="text-body-sm text-text-secondary">{selectedRecord.designation}</p>
              )}
              <StatusChip
                label={payrollStatusLabel(selectedRecord.status)}
                tone={payrollStatusTone(selectedRecord.status)}
              />
            </div>
            <div className="bg-surface-muted rounded-control phone:grid-cols-2 grid grid-cols-1 gap-4 p-4">
              <MoneyMetric label="Gross pay" value={formatMoney(selectedRecord.baseSalary)} />
              <MoneyMetric
                label="Total allowances"
                value={formatMoney(selectedRecord.allowanceTotal)}
              />
              <MoneyMetric label="Deductions" value={formatMoney(selectedRecord.deductions)} />
              <MoneyMetric label="Net pay" value={formatMoney(selectedRecord.netPay)} />
              <div className="bg-surface border-border-subtle rounded-control min-w-0 border p-3">
                <p className="text-overline text-text-muted">Disbursement date</p>
                <p className="text-body-sm text-text-primary mt-1.5 font-semibold break-words">
                  {disbursementLabel(selectedRecord)}
                </p>
              </div>
            </div>
            <section className="space-y-2">
              <h3 className="text-label text-text-primary font-semibold">Allowance breakdown</h3>
              {Object.keys(selectedRecord.allowanceBreakdown).length ? (
                <ul className="border-border-subtle divide-border-subtle rounded-control divide-y border px-3">
                  {Object.entries(selectedRecord.allowanceBreakdown).map(([name, value]) => (
                    <li key={name} className="flex items-center justify-between gap-3 py-2.5">
                      <span className="text-body-sm text-text-secondary">
                        {formatAllowanceName(name)}
                      </span>
                      <span className="text-body-sm text-text-primary font-semibold tabular-nums">
                        {formatMoney(numberValue(value))}
                      </span>
                    </li>
                  ))}
                </ul>
              ) : (
                <p className="text-body-sm text-text-secondary bg-surface-muted rounded-control p-3">
                  No category breakdown was included in this payroll record.
                </p>
              )}
            </section>
            <section className="space-y-2">
              <h3 className="text-label text-text-primary font-semibold">Deduction breakdown</h3>
              {Object.keys(selectedRecord.deductionBreakdown).length ? (
                <ul className="border-border-subtle divide-border-subtle rounded-control divide-y border px-3">
                  {Object.entries(selectedRecord.deductionBreakdown).map(([name, value]) => (
                    <li key={name} className="flex items-center justify-between gap-3 py-2.5">
                      <span className="text-body-sm text-text-secondary">
                        {formatAllowanceName(name)}
                      </span>
                      <span className="text-body-sm text-text-primary font-semibold tabular-nums">
                        {formatMoney(numberValue(value))}
                      </span>
                    </li>
                  ))}
                </ul>
              ) : (
                <p className="text-body-sm text-text-secondary bg-surface-muted rounded-control p-3">
                  No category breakdown was included in this payroll record.
                </p>
              )}
            </section>
          </div>
        ) : null}
      </Dialog>
    </PageLayout>
  )
}

function numberValue(value: number | string): number | null {
  const parsed = Number(value)
  return Number.isFinite(parsed) ? parsed : null
}
