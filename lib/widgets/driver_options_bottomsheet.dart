import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tmjapp/api/ride_api.dart';

class DriverOptionsBottomSheet extends StatefulWidget {
  final List<Map<String, dynamic>> driverOptions;
  final Function(Map<String, dynamic> option, String payment) onSelect;
  final String userId;
  final Map<String, dynamic> pickupLocation;
  final Map<String, dynamic> destinationLocation;

  const DriverOptionsBottomSheet({
    Key? key,
    required this.driverOptions,
    required this.onSelect,
    required this.userId,
    required this.pickupLocation,
    required this.destinationLocation,
  }) : super(key: key);

  @override
  State<DriverOptionsBottomSheet> createState() =>
      _DriverOptionsBottomSheetState();
}

class _DriverOptionsBottomSheetState extends State<DriverOptionsBottomSheet> {
  int selectedIndex = 0;
  String selectedPayment = 'Dinheiro';
  bool isLoading = false;

  void _createRideAndLoadProducts() async {
    setState(() {
      isLoading = true;
    });

    try {
      var response = await RideApi().createRide(
          widget.userId, widget.pickupLocation, widget.destinationLocation);

      if (response.result != null && response.result?['products'] != null) {
        List<Map<String, dynamic>> products =
            List<Map<String, dynamic>>.from(response.result?['products'] ?? []);
        widget.onSelect(products[selectedIndex], selectedPayment);
      } else {
        // Trate o caso de erro ou resposta inesperada
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao carregar produtos.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao criar a corrida.')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _createRideAndLoadProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: MediaQuery.of(context).size.height * 0.6,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Escolher uma viagem',
                  style: GoogleFonts.roboto(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: widget.driverOptions.length,
                  itemBuilder: (context, index) {
                    final option = widget.driverOptions[index];
                    final isSelected = selectedIndex == index;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedIndex = index;
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color:
                                isSelected ? Colors.black : Colors.transparent,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          color:
                              isSelected ? Colors.grey.shade100 : Colors.white,
                        ),
                        child: ListTile(
                          leading: Image.asset(option['image'],
                              width: 48, height: 48),
                          title: Row(
                            children: [
                              Text(
                                option['type'],
                                style: GoogleFonts.roboto(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (option['type'] == 'Comfort') ...[
                                const SizedBox(width: 8),
                                const Icon(Icons.person, size: 18),
                                const Text('4'),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.blue,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Text('Mais rápido.',
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 12)),
                                ),
                              ],
                            ],
                          ),
                          subtitle: Text(
                            option['time'] ?? '',
                            style: GoogleFonts.roboto(fontSize: 14),
                          ),
                          trailing: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'R\$ ${option['price']}',
                                style: GoogleFonts.roboto(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                              if (option['oldPrice'] != null)
                                Text(
                                  'R\$ ${option['oldPrice']}',
                                  style: GoogleFonts.roboto(
                                    fontSize: 12,
                                    color: Colors.grey,
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  children: [
                    const Icon(Icons.attach_money, color: Colors.green),
                    const SizedBox(width: 8),
                    DropdownButton<String>(
                      value: selectedPayment,
                      items: ['Dinheiro', 'Cartão', 'Pix']
                          .map(
                              (e) => DropdownMenuItem(value: e, child: Text(e)))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedPayment = value!;
                        });
                      },
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.arrow_forward_ios),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton.icon(
                  onPressed: isLoading ? null : _createRideAndLoadProducts,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    minimumSize: const Size.fromHeight(48),
                  ),
                  icon: const Icon(Icons.directions_car, color: Colors.white),
                  label: isLoading
                      ? const CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        )
                      : Text(
                          'Escolha ${widget.driverOptions[selectedIndex]['type']}',
                          style: const TextStyle(color: Colors.white),
                        ),
                ),
              ),
            ],
          ),
        ),
        if (isLoading)
          Container(
            color: Colors.black.withOpacity(0.5),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
      ],
    );
  }
}
