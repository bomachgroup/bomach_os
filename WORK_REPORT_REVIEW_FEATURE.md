# Daily Work Report Review Feature

## Overview

The Daily Work Report Review feature enables managers and supervisors to review, approve, reject, or request rework on employee daily work reports. This comprehensive system ensures quality control and provides constructive feedback to employees.

---

## Features

### 1. **Review Actions**

Managers can take three types of actions when reviewing a work report:

#### ✅ **Approve**
- Marks the report as "Approved"
- Requires feedback comments
- Sets the `approvedBy` and `approvedAt` fields
- Employee notification: Report has been approved

#### 🔄 **Request Rework**
- Marks the report as "Rework Required"
- Requires both feedback and specific rework instructions
- Enables employee to edit and resubmit the report
- Employee notification: Detailed instructions on what needs to be changed

#### ❌ **Reject**
- Marks the report as "Rejected"
- Requires feedback explanation
- Report cannot be edited again, must be resubmitted as new report
- Employee notification: Reason for rejection

---

## File Structure

### 1. **Work Report Review Dialog**
**File:** `lib/pages/hr/widget/work_report_review_dialog.dart`

Main dialog component for managers to review work reports.

#### Classes:

**`WorkReportReviewDialog`** (StatefulWidget)
- Main dialog widget for reviewing work reports
- Parameters:
  - `report` (DailyWorkReport): The report being reviewed
  - `reviewerName` (String?): Name of the reviewer/manager
  - `onReviewComplete` (Function): Callback when review is complete

**`WorkReportReviewResult`** (Data Class)
- Encapsulates review result data
- Fields:
  - `action` (ReviewAction): Approve, Reject, or Request Rework
  - `feedback` (String): Manager's feedback/comments
  - `reworkNotes` (String?): Specific instructions if rework requested
  - `reviewedAt` (DateTime): Timestamp of review

**`ReviewAction`** (Enum)
```dart
enum ReviewAction { approve, reject, requestRework }
```

### 2. **Work Report Page Integration**
**File:** `lib/pages/hr/work_report.dart`

Integrates the review dialog into the work report listing.

#### Key Methods:

**`_handleWorkReportReview(int index, DailyWorkReport updatedReport)`**
- Updates the work report in the list after review
- Triggers UI refresh with updated status

**`_openReviewDialog(BuildContext context, int index, DailyWorkReport report)`**
- Opens the review dialog
- Passes report data and callback handler

**`_buildActionMenu(BuildContext context, int index, DailyWorkReport report)`**
- Creates popup menu for each report row
- Options:
  - Review Report (for submitted reports)
  - Edit Report (only if Draft or Rework Required)

---

## UI Components

### Dialog Layout

```
┌─────────────────────────────────────────────┐
│ Review Work Report (Header)                 │
├─────────────────────────────────────────────┤
│                                             │
│ Employee Info Card                          │
│ ├─ Name, Email, Status, Date                │
│ └─ Hours, Mood, Activities count            │
│                                             │
│ Activities Summary                          │
│ ├─ Card for each activity                   │
│ └─ Category badges, hours, completion       │
│                                             │
│ Report Details                              │
│ ├─ Achievements                             │
│ ├─ Challenges                               │
│ └─ Next Day Plan                            │
│                                             │
│ ─────────────────────────────────────────── │
│                                             │
│ Review Actions (Select One)                 │
│ ├─ ✓ Approve Report                         │
│ ├─ 🔄 Request Rework                        │
│ └─ ❌ Reject Report                         │
│                                             │
│ Feedback (Required)                         │
│ └─ Multi-line text field                    │
│                                             │
│ Rework Instructions (If Rework Selected)    │
│ └─ Multi-line text field                    │
│                                             │
│ Info Message (Dynamic)                      │
│                                             │
├─────────────────────────────────────────────┤
│ [Cancel]  [Submit Review]                   │
└─────────────────────────────────────────────┘
```

### Action Selection UI

Each action is presented as a clickable card with:
- Icon (checkmark, edit, X)
- Action label
- Color-coded (green, orange, red)
- Selected state with radio button

---

## Data Models

### DailyWorkReport Fields Used

```dart
class DailyWorkReport {
  String id;
  String employeeId;
  String employeeName;
  String employeeEmail;
  DateTime reportDate;
  List<WorkActivity> activities;
  double hoursWorked;
  String mood;
  String challenges;
  String achievements;
  String nextDayPlan;
  bool submitted;
  DateTime? submittedAt;
  String? approvedBy;           // Set on approval
  DateTime? approvedAt;         // Set on approval
  String status;                // Updated to Approved/Rejected/Rework Required
}
```

### WorkActivity Fields

```dart
class WorkActivity {
  String id;
  String taskTitle;
  String description;
  String taskCategory;
  double hoursSpent;
  bool completed;
  List<String> tags;
}
```

---

## Usage Example

### Integrating Review Dialog

```dart
// In your work report list page
void _openReviewDialog(BuildContext context, int index, DailyWorkReport report) {
  showDialog(
    context: context,
    builder: (context) {
      return WorkReportReviewDialog(
        report: report,
        reviewerName: 'Manager Account', // Get from logged-in user
        onReviewComplete: (updatedReport) {
          _handleWorkReportReview(index, updatedReport);
        },
      );
    },
  );
}
```

### From Action Menu

```dart
PopupMenuButton<String>(
  onSelected: (String result) {
    if (result == 'view') {
      _openReviewDialog(context, index, report);
    }
  },
  itemBuilder: (BuildContext context) => [
    const PopupMenuItem<String>(
      value: 'view',
      child: Row(
        children: [
          Icon(Icons.fact_check_outlined, size: 18),
          SizedBox(width: 8),
          Text('Review Report'),
        ],
      ),
    ),
  ],
)
```

---

## Workflow

### Manager Review Process

1. **Navigate to Work Reports Page** (`/hr/work_report`)
2. **Select Report to Review**
   - View list of submitted reports
   - Click action menu (three dots)
   - Select "Review Report"

3. **Review Dialog Opens**
   - See employee info, activities, achievements, challenges
   - Read complete report details

4. **Select Review Action**
   - Approve: If report is satisfactory
   - Request Rework: If needs improvements (with instructions)
   - Reject: If report does not meet standards

5. **Provide Feedback**
   - Always required
   - Should be constructive and specific

6. **If Rework Requested**
   - Provide detailed instructions
   - Specify what needs to be changed
   - Give clear guidance for improvement

7. **Submit Review**
   - Report status updated immediately
   - Employee notified of decision

### Employee Response

**If Approved:**
- Report marked as "Approved"
- No further action needed
- Appears in approval history

**If Rework Required:**
- Report marked as "Rework Required"
- Report becomes editable again
- Employee receives detailed instructions
- Can edit and resubmit

**If Rejected:**
- Report marked as "Rejected"
- Cannot be edited
- Employee must create new report
- Must address feedback in new submission

---

## Status Flow Diagram

```
        ┌─────────┐
        │  Draft  │
        └────┬────┘
             │
        [Employee Submits]
             ↓
        ┌─────────────┐
        │ Submitted   │
        └────┬────────┘
             │
      ┌──────┼──────┬───────────┐
      │      │      │           │
  [Approve] [Reject] [Rework Requested]
      │      │      │           │
      ↓      ↓      ↓           ↓
  ┌────────┐┌────────┐ ┌─────────────────┐
  │Approved││Rejected│ │Rework Required  │
  └────────┘└────────┘ └────┬────────────┘
                            │
                    [Employee Re-edits]
                            │
                            ↓
                      ┌─────────────┐
                      │ Resubmitted │
                      └──────┬──────┘
                             │
                        [Review Again]
                             ↓
```

---

## Key Features

### 1. **Comprehensive Report View**
- Employee information displayed
- All activities with categories and hours
- Full report content (achievements, challenges, plans)
- Mood and productivity indicators

### 2. **Clear Action Selection**
- Three distinct options
- Visual feedback (colors, icons)
- Selected state clearly indicated
- Help text for each action

### 3. **Flexible Feedback**
- Required feedback field (for all actions)
- Conditional rework instructions field
- Dynamic info messages based on selected action

### 4. **Activity Display**
- Category badges with colors
- Completion status indicator
- Hours spent per activity
- Description and title

### 5. **Validation**
- Feedback is mandatory
- Rework instructions mandatory when requesting rework
- Action must be selected before submission
- Loading state during submission

### 6. **Success Feedback**
- SnackBar confirmation message
- Color-coded (green for approval, orange for rework, red for rejection)
- Dialog closes on successful submission
- Status updated in real-time

---

## Customization

### Reviewer Name
```dart
reviewerName: 'Manager Account', // Replace with logged-in user
```

### Activity Categories
Available categories (defined in `work_report_models.dart`):
- Development
- Testing
- Bug Fix
- Documentation
- Meeting
- Research
- Code Review
- Deployment
- Other

### Mood Options
- Happy 😊
- Neutral 😐
- Tired 😴
- Frustrated 😞

### Status Colors
```dart
Color _getStatusColor(String status) {
  case 'approved': return AppColors.green;
  case 'submitted': return AppColors.blue;
  case 'draft': return Color(0xFF64748B);
  case 'rejected': return AppColors.red;
}
```

---

## Integration Points

### 1. **Work Report Page**
- Import: `work_report_review_dialog.dart`
- Show review dialog on action menu selection
- Update report list after review

### 2. **Models**
- Uses: `DailyWorkReport`, `WorkActivity`
- Returns: `WorkReportReviewResult`

### 3. **Components Used**
- `MyText`, `MyTextFormField`, `MyElevatedButton`, `MyOutlinedButton`
- Standard Flutter widgets (Container, Dialog, Row, Column, etc.)

### 4. **State Management**
- Local state in dialog (feedback, rework notes)
- Parent page state management for list updates
- Callback-based communication

---

## Future Enhancements

### Planned Features

1. **Email Notifications**
   - Send review result to employee email
   - Include feedback and instructions

2. **Review History**
   - Track all reviews for a report
   - Show review timeline

3. **Analytics Dashboard**
   - Approval rate statistics
   - Common feedback patterns
   - Manager performance metrics

4. **Bulk Actions**
   - Review multiple reports at once
   - Apply same feedback to similar issues

5. **Report Templates**
   - Create feedback templates
   - Quick feedback insertion

6. **Reminders**
   - Automatic reminders for pending reviews
   - Overdue review alerts

7. **Approval Routing**
   - Multi-level approval workflow
   - Department-specific approvers

8. **Mobile Support**
   - Mobile-optimized review dialog
   - Touch-friendly action selection

---

## Error Handling

### Validation Errors
- **Empty Feedback**: "Please provide feedback for this review"
- **Missing Rework Notes**: "Please provide rework instructions"
- **No Action Selected**: Button disabled, help text shown

### Success States
- Report updated successfully
- SnackBar confirmation
- Dialog auto-closes
- List refreshes immediately

---

## Testing Checklist

- [ ] Open work report review dialog
- [ ] View employee information
- [ ] Verify all activities displayed correctly
- [ ] Select Approve action
- [ ] Provide feedback and submit
- [ ] Verify status changed to "Approved"
- [ ] Try Request Rework action
- [ ] Verify rework notes field appears
- [ ] Complete rework review
- [ ] Try Reject action
- [ ] Verify status changed to "Rejected"
- [ ] Check that canceled review doesn't update status
- [ ] Verify loading state during submission
- [ ] Test with reports of different statuses
- [ ] Test with different numbers of activities

---

## Files Modified/Created

### Created:
- `lib/pages/hr/widget/work_report_review_dialog.dart` - Main review dialog
- `WORK_REPORT_REVIEW_FEATURE.md` - This documentation

### Modified:
- `lib/pages/hr/work_report.dart` - Integration and action menu
- `lib/pages/hr/models/work_report_models.dart` - Already had necessary fields

---

## Support & Documentation

For questions or improvements, refer to:
1. `work_report_review_dialog.dart` - Dialog implementation
2. `work_report.dart` - Integration example
3. `work_report_models.dart` - Data structure
4. `CLAUDE.md` - Project guidelines

