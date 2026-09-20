import 'package:flutter/material.dart';

class SearchCustomersScreen extends StatefulWidget {
  const SearchCustomersScreen({super.key});

  @override
  State<SearchCustomersScreen> createState() => _SearchCustomersScreenState();
}

class _SearchCustomersScreenState extends State<SearchCustomersScreen> {
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, String>> _customers = [
    {
      "name": "Jane Smith",
      "email": "jane.smith@example.com",
      "phone": "+1 555-1234"
    },
    {
      "name": "John Brown",
      "email": "john.brown@example.com",
      "phone": "+1 555-5678"
    },
    {
      "name": "Sarah Williams",
      "email": "sarah.williams@example.com",
      "phone": "+1 555-8765"
    },
    {
      "name": "Michael Lee",
      "email": "michael.lee@example.com",
      "phone": "+1 555-4321"
    },
    {
      "name": "Emily Davis",
      "email": "emily.davis@example.com",
      "phone": "+1 555-2468"
    },
    {
      "name": "Daniel Wilson",
      "email": "daniel.wilson@example.com",
      "phone": "+1 555-1357"
    },
  ];

  List<Map<String, String>> _filteredCustomers = [];

  @override
  void initState() {
    super.initState();
    _filteredCustomers = List.from(_customers);
    _searchController.addListener(_filterCustomers);
  }

  void _filterCustomers() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredCustomers = List.from(_customers);
      } else {
        _filteredCustomers = _customers.where((customer) {
          return customer["name"]!.toLowerCase().contains(query) ||
              customer["email"]!.toLowerCase().contains(query) ||
              customer["phone"]!.toLowerCase().contains(query);
        }).toList();
      }
    });
  }

  void _clearSearch() {
    _searchController.clear();
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Widget _buildCustomerCard(Map<String, String> customer) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.green.shade200,
          child: Text(customer["name"]![0]),
        ),
        title: Text(
          customer["name"]!,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(customer["email"]!),
            Text(customer["phone"]!),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.message, color: Colors.green),
          onPressed: () =>
              _showSnackBar("Opening chat with ${customer["name"]}"),
        ),
        onTap: () => _showSnackBar("Opening chat with ${customer["name"]}"),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final int resultCount = _filteredCustomers.length;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.green,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Search Customers"),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: "Search customers...",
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: _clearSearch,
                        )
                      : null,
                  filled: true,
                  fillColor: Colors.grey.shade200,
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              resultCount == _customers.length
                  ? "$resultCount customers"
                  : "$resultCount customers found",
              style: const TextStyle(fontSize: 14, color: Colors.black54),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: _filteredCustomers.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.search_off,
                              size: 48, color: Colors.black45),
                          SizedBox(height: 8),
                          Text(
                            "No customers found",
                            style: TextStyle(
                                fontSize: 16, color: Colors.black54),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: _filteredCustomers.length,
                      itemBuilder: (context, index) {
                        return _buildCustomerCard(_filteredCustomers[index]);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
