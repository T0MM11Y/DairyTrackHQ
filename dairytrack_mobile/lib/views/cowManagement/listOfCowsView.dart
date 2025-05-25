import 'package:dairytrack_mobile/views/cowManagement/makeEditCowsView.dart';
import 'package:flutter/material.dart';
import 'package:dairytrack_mobile/controller/APIURL1/cowManagementController.dart';
import 'package:intl/intl.dart';
import 'package:dairytrack_mobile/controller/APIURL1/cattleDistributionController.dart';
import 'package:open_file/open_file.dart'; // Import open_file

class ListOfCowsView extends StatefulWidget {
  @override
  _ListOfCowsViewState createState() => _ListOfCowsViewState();
}

class _ListOfCowsViewState extends State<ListOfCowsView> {
  final CowManagementController _controller = CowManagementController();
  final CattleDistributionController _cattleController =
      CattleDistributionController();
  List<Cow> _cows = [];
  List<Cow> _filteredCows = [];
  bool _isLoading = true;
  String _errorMessage = '';
  String _searchQuery = '';
  String _selectedGender = '';
  String _selectedPhase = '';
  String _sortField = 'name';
  bool _sortAscending = true;

  final Map<String, String> _lactationPhaseDescriptions = {
    'Dry':
        'The cow is not producing milk and is in a resting phase, allowing her body to recover and prepare for the next lactation cycle.',
    'Early':
        'The cow is in the early stage of lactation, characterized by high milk production as she adjusts after calving.',
    'Mid':
        'The cow is in the middle stage of lactation, where milk production is generally stable after the initial peak.',
    'Late':
        'The cow is in the late stage of lactation, with milk production gradually decreasing as the pregnancy progresses.',
  };

  @override
  void initState() {
    super.initState();
    _fetchCows();
  }

  Future<void> _fetchCows() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final cows = await _controller.listCows();
      setState(() {
        _cows = cows;
        _applyFiltersAndSort();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  void _applyFiltersAndSort() {
    List<Cow> filtered = List.from(_cows);

    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where((cow) =>
              cow.name.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }

    if (_selectedGender.isNotEmpty) {
      filtered =
          filtered.where((cow) => cow.gender == _selectedGender).toList();
    }

    if (_selectedPhase.isNotEmpty) {
      filtered = filtered
          .where((cow) => cow.lactationPhase == _selectedPhase)
          .toList();
    }

    filtered.sort((a, b) {
      int comparison = 0;
      switch (_sortField) {
        case 'name':
          comparison = a.name.toLowerCase().compareTo(b.name.toLowerCase());
          break;
        case 'weight':
          comparison = a.weight.compareTo(b.weight);
          break;
        case 'age':
          comparison = a.age.compareTo(b.age);
          break;
      }
      return _sortAscending ? comparison : -comparison;
    });

    _filteredCows = filtered;
  }

  void _deleteCow(int cowId) async {
    // Ambil daftar user yang mengelola sapi
    final managersResponse = await _cattleController.getCowManagers(cowId);

    if (managersResponse['success'] == true &&
        managersResponse['managers'].isNotEmpty) {
      final managerList = (managersResponse['managers'] as List)
          .map((manager) => "${manager['username']}")
          .join(", ");

      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Colors.grey[900], // Dark theme background
          title: Text("Delete Cow",
              style: TextStyle(color: Colors.white)), // White text
          content: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: "This cow is managed by: ",
                  style: TextStyle(color: Colors.white70),
                ),
                TextSpan(
                  text: managerList,
                  style: TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextSpan(
                  text: ". Are you sure you want to delete this cow?",
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text("Cancel", style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text("Delete", style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );

      if (confirm == true) {
        final response = await _controller.deleteCow(cowId);
        if (response['success'] == true) {
          _showSnackBar("Cow deleted successfully.");
          _fetchCows();
        } else {
          _showSnackBar(response['message'] ?? "Failed to delete cow.");
        }
      }
    } else {
      // Jika tidak ada manager, langsung tampilkan konfirmasi penghapusan
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Colors.grey[900], // Dark theme background
          title: Text("Delete Cow",
              style: TextStyle(color: Colors.white)), // White text
          content: Text("Are you sure you want to delete this cow?",
              style: TextStyle(color: Colors.white70)), // Lighter text
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text("Cancel", style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text("Delete", style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );

      if (confirm == true) {
        final response = await _controller.deleteCow(cowId);
        if (response['success'] == true) {
          _showSnackBar("Cow deleted successfully.");
          _fetchCows();
        } else {
          _showSnackBar(response['message'] ?? "Failed to delete cow.");
        }
      }
    }
  }

  void _navigateToEditCow(Cow cow) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MakeCowsView(
          initialCowData: {
            '_id': cow.id.toString(),
            'name': cow.name,
            // Pastikan cow.birth diubah menjadi DateTime sebelum diformat
            'birth': cow.birth != null
                ? DateFormat('yyyy-MM-dd').format(
                    DateFormat("EEE, dd MMM yyyy HH:mm:ss 'GMT'")
                        .parse(cow.birth))
                : '',
            'breed': cow.breed,
            'lactation_phase': cow.lactationPhase,
            'weight': cow.weight,
            'gender': cow.gender,
          },
        ),
      ),
    );
    if (result == true) {
      _fetchCows();
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          "List of Cows",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blueGrey[800],
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list, color: Colors.white),
            onPressed: () {
              _showFilterBottomSheet(context);
            },
          ),
          IconButton(
            icon: Icon(Icons.file_download, color: Colors.white),
            onPressed: () {
              _showExportDialog(context);
            },
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(child: Text(_errorMessage))
              : RefreshIndicator(
                  onRefresh: _fetchCows,
                  child: Column(
                    children: [
                      _buildSearchBar(),
                      _buildSortingOptions(),
                      Expanded(
                        child: _filteredCows.isEmpty
                            ? Center(child: Text("No cows found"))
                            : ListView(
                                children: [
                                  _buildStatisticsCard(),
                                  _buildLactationPhaseInfo(),
                                  ..._filteredCows
                                      .map((cow) => _buildCowCard(cow))
                                      .toList(),
                                  SizedBox(height: 80),
                                ],
                              ),
                      ),
                    ],
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => MakeCowsView()),
          );
          if (result == true) {
            setState(() {
              _fetchCows();
            });
          }
        },
        child: Icon(Icons.add, color: Colors.white),
        backgroundColor: Colors.blueGrey[800],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search cows...',
          prefixIcon: Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          filled: true,
          fillColor: Colors.grey[100],
          contentPadding: EdgeInsets.symmetric(vertical: 0),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: () {
                    setState(() {
                      _searchQuery = '';
                      _applyFiltersAndSort();
                    });
                  },
                )
              : null,
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
            _applyFiltersAndSort();
          });
        },
      ),
    );
  }

  Widget _buildSortingOptions() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Text('Sort by: '),
          SizedBox(width: 8),
          ...['name', 'weight', 'age'].map((field) {
            String label = field[0].toUpperCase() + field.substring(1);
            return Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: ChoiceChip(
                label: Text(label),
                selected: _sortField == field,
                onSelected: (selected) {
                  if (selected) {
                    setState(() {
                      if (_sortField == field) {
                        _sortAscending = !_sortAscending;
                      } else {
                        _sortField = field;
                        _sortAscending = true;
                      }
                      _applyFiltersAndSort();
                    });
                  }
                },
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildCowCard(Cow cow) {
    // Pastikan cow.birth diubah menjadi DateTime sebelum digunakan
    DateTime birthDate;
    try {
      birthDate = DateFormat("EEE, dd MMM yyyy HH:mm:ss 'GMT'")
          .parse(cow.birth, true)
          .toLocal();
    } catch (e) {
      return Card(
        child: ListTile(
          title: Text(cow.name),
          subtitle: Text("Invalid birth date format"),
        ),
      );
    }

    final now = DateTime.now();
    final ageYears = now.year - birthDate.year;
    final ageMonths = now.month - birthDate.month + (ageYears * 12);

    final displayYears = ageMonths ~/ 12;
    final displayMonths = ageMonths % 12;

    return Card(
      elevation: 1,
      margin: EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor:
              cow.gender == 'Female' ? Colors.green[100] : Colors.blue[100],
          child: Icon(
            cow.gender == 'Female' ? Icons.female : Icons.male,
            color: cow.gender == 'Female' ? Colors.green : Colors.blue,
          ),
        ),
        title: Text(
          cow.name,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          "Age: $displayYears years, $displayMonths months, Weight: ${cow.weight} kg",
        ),
        trailing: Chip(
          label: Text(cow.gender),
          backgroundColor:
              cow.gender == 'Female' ? Colors.green[50] : Colors.blue[50],
          labelStyle: TextStyle(
            color: cow.gender == 'Female' ? Colors.green : Colors.blue,
            fontSize: 12,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCowInfoRow(
                    'Age', "$displayYears years, $displayMonths months"),
                _buildCowInfoRow('Weight', "${cow.weight} kg"),
                _buildCowInfoRow('Phase', cow.lactationPhase),
                Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton.icon(
                      icon: const Icon(
                        Icons.edit,
                        size: 18,
                        color: Colors.white,
                      ),
                      label: const Text(
                        "Edit",
                        style: TextStyle(fontSize: 12, color: Colors.white),
                      ),
                      onPressed: () => _navigateToEditCow(cow),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[400],
                        padding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 6,
                        ),
                        shape: RoundedRectangleBorder(),
                      ),
                    ),
                    SizedBox(width: 4),
                    ElevatedButton.icon(
                      icon: const Icon(
                        Icons.delete,
                        size: 18,
                        color: Colors.white,
                      ),
                      label: const Text(
                        "Delete",
                        style: TextStyle(fontSize: 12, color: Colors.white),
                      ),
                      onPressed: () => _deleteCow(cow.id),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[400],
                        padding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 6,
                        ),
                        shape: RoundedRectangleBorder(),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCowInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          SizedBox(width: 8),
          Text('$label:', style: TextStyle(fontWeight: FontWeight.w500)),
          SizedBox(width: 8),
          Expanded(
            child: Text(value, style: TextStyle(color: Colors.grey[800])),
          ),
        ],
      ),
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 16.0,
              right: 16.0,
              top: 16.0,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      'Filter Cows',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white, // Warna teks untuk tema gelap
                      ),
                    ),
                  ),
                  SizedBox(height: 24),
                  _buildGenderFilter(setState),
                  SizedBox(height: 16),
                  _buildPhaseFilter(setState),
                  SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        this.setState(() {
                          _applyFiltersAndSort();
                        });
                      },
                      child: Text(
                        'Apply Filters',
                        style: TextStyle(
                          color: Colors.white, // Warna teks tombol
                          fontSize: 16,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueGrey[800], // Warna tombol
                        padding: EdgeInsets.symmetric(
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            8.0,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                ],
              ),
            ),
          );
        },
      ),
      backgroundColor: Colors.grey[900], // Latar belakang untuk tema gelap
    );
  }

  Widget _buildGenderFilter(StateSetter setState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Text(
            'Gender',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white, // Warna teks untuk tema gelap
            ),
          ),
        ),
        Row(
          children: [
            _buildRadioListTile(setState, 'All', '', _selectedGender),
            _buildRadioListTile(setState, 'Female', 'Female', _selectedGender),
            _buildRadioListTile(setState, 'Male', 'Male', _selectedGender),
          ],
        ),
      ],
    );
  }

  Widget _buildPhaseFilter(StateSetter setState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Text(
            'Lactation Phase',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white, // Warna teks untuk tema gelap
            ),
          ),
        ),
        DropdownButtonFormField<String>(
          value: _selectedPhase,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
            filled: true,
            fillColor: Colors.grey[800], // Latar belakang dropdown
          ),
          dropdownColor: Colors.grey[900], // Latar belakang dropdown item
          items: [
            DropdownMenuItem(
              value: '',
              child: Text(
                'All',
                style: TextStyle(color: Colors.white), // Warna teks dropdown
              ),
            ),
            ..._lactationPhaseDescriptions.keys.map((phase) {
              return DropdownMenuItem(
                value: phase,
                child: Text(
                  phase,
                  style: TextStyle(color: Colors.white), // Warna teks dropdown
                ),
              );
            }).toList(),
          ],
          onChanged: (value) {
            setState(() {
              _selectedPhase = value!;
            });
          },
        ),
      ],
    );
  }

  Widget _buildRadioListTile(
      StateSetter setState, String title, String value, String groupValue) {
    return Expanded(
      child: RadioListTile<String>(
        title: Text(
          title,
          style:
              TextStyle(color: Colors.white), // Warna teks diubah menjadi white
        ),
        value: value,
        groupValue: groupValue,
        onChanged: (newValue) {
          setState(() {
            _selectedGender = newValue!;
          });
        },
        activeColor: Colors.blueGrey, // Warna saat radio button aktif
        contentPadding: EdgeInsets.zero,
      ),
    );
  }

  void _showExportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Row(
          children: [
            Icon(Icons.download, color: Colors.amber),
            SizedBox(width: 8),
            Text(
              "Export Data",
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(
                Icons.picture_as_pdf,
                color: Colors.redAccent,
              ),
              title: Text(
                "Export as PDF",
                style: TextStyle(color: Colors.white),
              ),
              tileColor: Colors.transparent,
              onTap: () async {
                Navigator.pop(context);
                setState(() => _isLoading = true);

                final scaffoldMessenger = ScaffoldMessenger.of(context);
                final navigator = Navigator.of(context);

                final response = await _controller.exportCowsToPDF();

                if (!mounted) return;
                setState(() => _isLoading = false);

                if (response['success']) {
                  final filePath = response['filePath'] ?? '';
                  if (filePath.isNotEmpty) {
                    print("PDF file path: $filePath");

                    if (mounted) {
                      showDialog(
                        context: navigator.context,
                        builder: (context) => AlertDialog(
                          backgroundColor: Colors.grey[900],
                          title: Row(
                            children: [
                              Icon(Icons.picture_as_pdf,
                                  color: Colors.redAccent),
                              SizedBox(width: 8),
                              Text("PDF Exported",
                                  style: TextStyle(color: Colors.white)),
                            ],
                          ),
                          content: Text(
                            "PDF export successful.\n\nFile saved at:\n$filePath",
                            style: TextStyle(color: Colors.white70),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () async {
                                Navigator.pop(context);
                                final result = await OpenFile.open(filePath);
                                if (!mounted) return;
                                if (result.type != ResultType.done) {
                                  scaffoldMessenger.showSnackBar(
                                    SnackBar(
                                        content: Text(
                                            'Failed to open file: ${result.message}')),
                                  );
                                }
                              },
                              child: Text("Open File",
                                  style: TextStyle(color: Colors.amber)),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text("Close",
                                  style: TextStyle(color: Colors.white)),
                            ),
                          ],
                        ),
                      );
                    }
                  } else {
                    if (mounted) {
                      scaffoldMessenger.showSnackBar(
                        SnackBar(
                            content:
                                Text('File path is empty, file not found!')),
                      );
                    }
                  }
                } else {
                  if (mounted) {
                    scaffoldMessenger.showSnackBar(
                      SnackBar(
                          content:
                              Text(response['message'] ?? 'Export failed')),
                    );
                  }
                }
              },
            ),
            ListTile(
              leading: Icon(
                Icons.table_chart,
                color: Colors.greenAccent,
              ),
              title: Text(
                "Export as Excel",
                style: TextStyle(color: Colors.white),
              ),
              tileColor: Colors.transparent,
              onTap: () async {
                Navigator.pop(context);
                setState(() => _isLoading = true);

                final scaffoldMessenger = ScaffoldMessenger.of(context);
                final navigator = Navigator.of(context);

                final response = await _controller.exportCowsToExcel();

                if (!mounted) return;
                setState(() => _isLoading = false);

                if (response['success']) {
                  final filePath = response['filePath'] ?? '';
                  if (filePath.isNotEmpty) {
                    print("Excel file path: $filePath");

                    if (mounted) {
                      showDialog(
                        context: navigator.context,
                        builder: (context) => AlertDialog(
                          backgroundColor: Colors.grey[900],
                          title: Row(
                            children: [
                              Icon(Icons.table_chart,
                                  color: Colors.greenAccent),
                              SizedBox(width: 8),
                              Text("Excel Exported",
                                  style: TextStyle(color: Colors.white)),
                            ],
                          ),
                          content: Text(
                            "Excel export successful.\n\nFile saved at:\n$filePath",
                            style: TextStyle(color: Colors.white70),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () async {
                                Navigator.pop(context);
                                final result = await OpenFile.open(filePath);
                                if (!mounted) return;
                                if (result.type != ResultType.done) {
                                  scaffoldMessenger.showSnackBar(
                                    SnackBar(
                                        content: Text(
                                            'Failed to open file: ${result.message}')),
                                  );
                                }
                              },
                              child: Text("Open File",
                                  style: TextStyle(color: Colors.amber)),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text("Close",
                                  style: TextStyle(color: Colors.white)),
                            ),
                          ],
                        ),
                      );
                    }
                  } else {
                    if (mounted) {
                      scaffoldMessenger.showSnackBar(
                        SnackBar(
                            content:
                                Text('File path is empty, file not found!')),
                      );
                    }
                  }
                } else {
                  if (mounted) {
                    scaffoldMessenger.showSnackBar(
                      SnackBar(
                          content:
                              Text(response['message'] ?? 'Export failed')),
                    );
                  }
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Cancel",
              style: TextStyle(color: Colors.amber),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenderStatistics(int femaleCount, double femalePercent,
      int maleCount, double malePercent) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Gender Distribution',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Female: $femaleCount (${femalePercent.toStringAsFixed(1)}%)',
                  ),
                  SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: femalePercent / 100,
                    backgroundColor: Colors.grey[200],
                    color: Colors.green[300],
                  ),
                ],
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Male: $maleCount (${malePercent.toStringAsFixed(1)}%)',
                  ),
                  SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: malePercent / 100,
                    backgroundColor: Colors.grey[200],
                    color: Colors.blue[300],
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLactationPhaseStatistics(Map<String, int> phaseCounts) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Lactation Phases',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        ...phaseCounts.entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 4.0),
            child: Text('${entry.key}: ${entry.value} cows'),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildStatisticsCard() {
    int femaleCount = _cows.where((cow) => cow.gender == 'Female').length;
    int maleCount = _cows.where((cow) => cow.gender == 'Male').length;
    double femalePercent =
        _cows.isEmpty ? 0 : (femaleCount / _cows.length) * 100;
    double malePercent = _cows.isEmpty ? 0 : (maleCount / _cows.length) * 100;

    Map<String, int> phaseCounts = {};
    for (var cow in _cows) {
      phaseCounts[cow.lactationPhase] =
          (phaseCounts[cow.lactationPhase] ?? 0) + 1;
    }

    return Card(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Cow Statistics',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            _buildGenderStatistics(
                femaleCount, femalePercent, maleCount, malePercent),
            SizedBox(height: 16),
            _buildLactationPhaseStatistics(phaseCounts),
          ],
        ),
      ),
    );
  }

  Widget _buildLactationPhaseInfo() {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Lactation Phase Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            ..._lactationPhaseDescriptions.entries.map((entry) {
              Color phaseColor = _getPhaseColor(entry.key);
              return _buildPhaseInfoContainer(
                  entry.key, entry.value, phaseColor);
            }).toList(),
          ],
        ),
      ),
    );
  }

  Color _getPhaseColor(String phase) {
    switch (phase) {
      case 'Dry':
        return Colors.brown[100]!;
      case 'Early':
        return Colors.green[100]!;
      case 'Mid':
        return Colors.yellow[100]!;
      case 'Late':
        return Colors.orange[100]!;
      default:
        return Colors.grey[100]!;
    }
  }

  Widget _buildPhaseInfoContainer(
      String phase, String description, Color color) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            phase,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 4),
          Text(description),
        ],
      ),
    );
  }
}
