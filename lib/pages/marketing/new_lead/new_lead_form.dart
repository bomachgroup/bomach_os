import 'package:bomach_os/components/text/my_text.dart';
import 'package:bomach_os/pages/marketing/models/marketing_lead.dart';
import 'package:bomach_os/src/constants/colors.dart';
import 'package:bomach_os/src/constants/textstyle.dart';
import 'package:flutter/material.dart';

class NewLeadForm extends StatefulWidget {
  const NewLeadForm({super.key});

  @override
  State<NewLeadForm> createState() => _NewLeadFormState();
}

class _NewLeadFormState extends State<NewLeadForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _budgetController = TextEditingController();
  final _sourceController = TextEditingController();
  final _notesController = TextEditingController();

  MarketingDivision _selectedDivision = MarketingDivision.re;
  LeadStage _selectedStage = LeadStage.newLead;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _budgetController.dispose();
    _sourceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const MyText('New Lead', style: AppTextStyles.displayLg),
        const SizedBox(height: 4),
        const MyText(
          'Register a new lead into the pipeline',
          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 15, color: AppColors.textMuted),
        ),
        const SizedBox(height: 24),
        Expanded(
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [BoxShadow(color: Color(0x0A000000), blurRadius: 10, offset: Offset(0, 2))],
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Contact Information', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 16),
                    _buildTextField('Full Name', _nameController, Icons.person_outline),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: _buildTextField('Phone Number', _phoneController, Icons.phone_outlined)),
                        const SizedBox(width: 12),
                        Expanded(child: _buildTextField('Email', _emailController, Icons.email_outlined)),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Text('Lead Details', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: _buildDivisionDropdown()),
                        const SizedBox(width: 12),
                        Expanded(child: _buildStageDropdown()),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: _buildTextField('Budget Range', _budgetController, Icons.account_balance_wallet_outlined)),
                        const SizedBox(width: 12),
                        Expanded(child: _buildTextField('Lead Source', _sourceController, Icons.campaign_outlined)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildTextField('Notes', _notesController, Icons.notes_outlined, maxLines: 3),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.borderSubtle),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          ),
                          child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
                        ),
                        const SizedBox(width: 12),
                        FilledButton(
                          onPressed: _submit,
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          ),
                          child: const Text('Create Lead', style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, IconData icon, {int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 18),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.borderSubtle),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primary),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
    );
  }

  Widget _buildDivisionDropdown() {
    return DropdownButtonFormField<MarketingDivision>(
      initialValue: _selectedDivision,
      decoration: InputDecoration(
        labelText: 'Division',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.borderSubtle),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
      items: MarketingDivision.values.map((div) {
        return DropdownMenuItem(value: div, child: Text(div.label));
      }).toList(),
      onChanged: (val) {
        if (val != null) setState(() => _selectedDivision = val);
      },
    );
  }

  Widget _buildStageDropdown() {
    return DropdownButtonFormField<LeadStage>(
      initialValue: _selectedStage,
      decoration: InputDecoration(
        labelText: 'Stage',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.borderSubtle),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
      items: LeadStage.values.map((stage) {
        return DropdownMenuItem(value: stage, child: Text(stage.label));
      }).toList(),
      onChanged: (val) {
        if (val != null) setState(() => _selectedStage = val);
      },
    );
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lead created successfully'), backgroundColor: AppColors.success),
      );
      Navigator.pop(context);
    }
  }
}
