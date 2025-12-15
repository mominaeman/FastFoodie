import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AdminDatabaseScreen extends StatefulWidget {
  const AdminDatabaseScreen({super.key});

  @override
  State<AdminDatabaseScreen> createState() => _AdminDatabaseScreenState();
}

class _AdminDatabaseScreenState extends State<AdminDatabaseScreen> {
  List<dynamic> _tableStats = [];
  bool _isLoading = true;
  String? _error;
  String? _selectedTable;
  List<dynamic> _tableData = [];
  bool _loadingTableData = false;

  @override
  void initState() {
    super.initState();
    _loadTableStats();
  }

  Future<void> _loadTableStats() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final stats = await ApiService.getTableStats();
      setState(() {
        _tableStats = stats;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load table statistics: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadTableData(String tableName) async {
    setState(() {
      _selectedTable = tableName;
      _loadingTableData = true;
    });

    try {
      final data = await ApiService.getTableData(tableName);
      setState(() {
        _tableData = data;
        _loadingTableData = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load $tableName data: $e';
        _loadingTableData = false;
      });
    }
  }

  Color _getStatusColor(int count) {
    if (count == 0) return Colors.red;
    if (count < 5) return Colors.orange;
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Database Inspector'),
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadTableStats,
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(_error!, style: const TextStyle(color: Colors.red)),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadTableStats,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              )
              : Column(
                children: [
                  // Table Statistics Section
                  Expanded(
                    flex: 1,
                    child: Card(
                      margin: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.all(16),
                            child: Text(
                              'Table Statistics',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const Divider(height: 1),
                          Expanded(
                            child: ListView.builder(
                              itemCount: _tableStats.length,
                              itemBuilder: (context, index) {
                                final stat = _tableStats[index];
                                final tableName = stat['table_name'];
                                final rowCount = int.parse(
                                  stat['row_count'].toString(),
                                );

                                return ListTile(
                                  leading: Icon(
                                    Icons.table_chart,
                                    color: _getStatusColor(rowCount),
                                  ),
                                  title: Text(
                                    tableName.toUpperCase(),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'monospace',
                                    ),
                                  ),
                                  trailing: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _getStatusColor(
                                        rowCount,
                                      ).withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: _getStatusColor(rowCount),
                                      ),
                                    ),
                                    child: Text(
                                      '$rowCount rows',
                                      style: TextStyle(
                                        color: _getStatusColor(rowCount),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  onTap: () => _loadTableData(tableName),
                                  selected: _selectedTable == tableName,
                                  selectedTileColor: Colors.deepPurple
                                      .withOpacity(0.1),
                                );
                              },
                            ),
                          ),
                          // Summary Footer
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              border: Border(
                                top: BorderSide(color: Colors.grey.shade300),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Total Tables:',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  '${_tableStats.length}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: Colors.deepPurple,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Table Data Section
                  if (_selectedTable != null)
                    Expanded(
                      flex: 2,
                      child: Card(
                        margin: const EdgeInsets.only(
                          left: 16,
                          right: 16,
                          bottom: 16,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.dataset,
                                    color: Colors.deepPurple,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    _selectedTable!.toUpperCase(),
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    '${_tableData.length} rows',
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Divider(height: 1),
                            Expanded(
                              child:
                                  _loadingTableData
                                      ? const Center(
                                        child: CircularProgressIndicator(),
                                      )
                                      : _tableData.isEmpty
                                      ? Center(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.inbox,
                                              size: 64,
                                              color: Colors.grey.shade400,
                                            ),
                                            const SizedBox(height: 16),
                                            Text(
                                              'No data in this table',
                                              style: TextStyle(
                                                color: Colors.grey.shade600,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                      : ListView.builder(
                                        padding: const EdgeInsets.all(8),
                                        itemCount: _tableData.length,
                                        itemBuilder: (context, index) {
                                          final row = _tableData[index];
                                          return Card(
                                            margin: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            child: ExpansionTile(
                                              title: Text(
                                                'Row ${index + 1}',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              subtitle: Text(
                                                _getRowPreview(row),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  color: Colors.grey.shade600,
                                                  fontSize: 12,
                                                ),
                                              ),
                                              children: [
                                                Padding(
                                                  padding: const EdgeInsets.all(
                                                    16,
                                                  ),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children:
                                                        row.keys.map<Widget>((
                                                          key,
                                                        ) {
                                                          return Padding(
                                                            padding:
                                                                const EdgeInsets.symmetric(
                                                                  vertical: 4,
                                                                ),
                                                            child: Row(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                SizedBox(
                                                                  width: 120,
                                                                  child: Text(
                                                                    '$key:',
                                                                    style: const TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      color:
                                                                          Colors
                                                                              .deepPurple,
                                                                      fontFamily:
                                                                          'monospace',
                                                                    ),
                                                                  ),
                                                                ),
                                                                Expanded(
                                                                  child: Text(
                                                                    row[key]
                                                                        .toString(),
                                                                    style: const TextStyle(
                                                                      fontFamily:
                                                                          'monospace',
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          );
                                                        }).toList(),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
    );
  }

  String _getRowPreview(Map<String, dynamic> row) {
    final keys = row.keys.take(3).toList();
    final preview = keys.map((key) => '${row[key]}').join(' | ');
    return preview;
  }
}
