
class Document {
  final String title;
  final String category; // e.g., Report, Contract, Invoice, Proposal
  final String restriction; // e.g., Available, Restricted
  final String description;
  final String client;
  final String uploadedBy;
  final String uploadedDate;
  final String lastModified;
  final String size;
  final int downloads;

  Document({
    required this.title,
    required this.category,
    required this.restriction,
    required this.description,
    required this.client,
    required this.uploadedBy,
    required this.uploadedDate,
    required this.lastModified,
    required this.size,
    required this.downloads,
  });
}


final List<Document> mockDocuments = [
  Document(
    title: 'Lekki Survey Final Report.pdf',
    category: 'Report',
    restriction: 'Available',
    description: 'Complete surveying report for Lekki Phase 2 residents',
    client: 'Lagos Property Development Ltd',
    uploadedBy: 'John Doe',
    uploadedDate: '5 Feb 2024',
    lastModified: '7 Feb 2024',
    size: '4.2 MB',
    downloads: 8,
  ),
  Document(
    title: 'Environmental Assessment Guidelines.pdf',
    category: 'Other',
    restriction: 'Restricted',
    description: 'Environmental impact assessment guidelines and pro',
    client: 'Rivers State Development Company',
    uploadedBy: 'Dr. Emeka Okafor',
    uploadedDate: '3 Feb 2024',
    lastModified: '4 Feb 2024',
    size: '3.5 MB',
    downloads: 1,
  ),
  Document(
    title: 'Project Contract - Highway Survey.pdf',
    category: 'Contract',
    restriction: 'Available',
    description: 'Signed contract for Abuja-Kaduna highway expansion',
    client: 'Abuja Infrastructure Company',
    uploadedBy: 'Grace Adebayo',
    uploadedDate: '28 Jan 2024',
    lastModified: '6 Feb 2024',
    size: '2.8 MB',
    downloads: 5,
  ),
  Document(
    title: 'Monthly Invoice - January 2024.pdf',
    category: 'Invoice',
    restriction: 'Available',
    description: 'Invoice for services rendered in January 2024',
    client: 'Lagos Property Development Ltd',
    uploadedBy: 'Grace Adebayo',
    uploadedDate: '1 Feb 2024',
    lastModified: '3 Feb 2024',
    size: '0.8 MB',
    downloads: 3,
  ),
  Document(
    title: 'Project Proposal - Housing Estate.pdf',
    category: 'Proposal',
    restriction: 'Available',
    description: 'Comprehensive proposal for 200-unit housing estate',
    client: 'Kano State Housing Corporation',
    uploadedBy: 'Dr. Emeka Okafor',
    uploadedDate: '30 Jan 2024',
    lastModified: '6 Feb 2024',
    size: '6.1 MB',
    downloads: 12,
  ),
  Document(
    title: 'Payment Receipt - February 2024.pdf',
    category: 'Invoice',
    restriction: 'Available',
    description: 'Payment receipt for February 2024 services',
    client: 'Abuja Infrastructure Company',
    uploadedBy: 'Grace Adebayo',
    uploadedDate: '7 Feb 2024',
    lastModified: '7 Feb 2024',
    size: '0.5 MB',
    downloads: 2,
  ),
];
