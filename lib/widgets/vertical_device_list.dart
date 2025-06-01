import 'package:flutter/material.dart';
import 'package:forui/forui.dart'; // Import forui
import 'package:flutter/services.dart';
import '../services/firestore/installtions.dart';

class VerticalDeviceList extends StatelessWidget {
  const VerticalDeviceList({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      // Added SingleChildScrollView
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          CustomPortal(), // Spacing between buttons
          StreamBuilder<List<Map<String, dynamic>>>(
            stream: watchInstallationData(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              }
              final installations = snapshot.data ?? [];
              return ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: installations.length,
                itemBuilder: (context, index) {
                  final doc = installations[index];
                  // Replace direct Card/ListTile with _HoverableListTile
                  return _HoverableListTile(doc: doc);
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

class CustomPortal extends StatefulWidget {
  const CustomPortal({super.key});

  @override
  State<CustomPortal> createState() => _CustomPortalState();
}

class _CustomPortalState extends State<CustomPortal> {
  final controllerPortal = OverlayPortalController();
  final double _textSpacing = 4;

  // Text controllers
  final nameController = TextEditingController();
  final panelPowerController = TextEditingController();
  final panelNumberController = TextEditingController();
  final maximumVoltageController = TextEditingController();
  final tiltController = TextEditingController();
  final azimuthController = TextEditingController();

  // Title color states for each field
  Color nameTitleColor = Colors.black;
  Color panelPowerTitleColor = Colors.black;
  Color panelNumberTitleColor = Colors.black;
  Color maximumVoltageTitleColor = Colors.black;
  Color tiltTitleColor = Colors.black;
  Color azimuthTitleColor = Colors.black;

  @override
  void initState() {
    super.initState();
    // Add listeners to revert all title colors to black when typing in any field
    nameController.addListener(_revertAllTitleColors);
    panelPowerController.addListener(_revertAllTitleColors);
    panelNumberController.addListener(_revertAllTitleColors);
    maximumVoltageController.addListener(_revertAllTitleColors);
    tiltController.addListener(_revertAllTitleColors);
    azimuthController.addListener(_revertAllTitleColors);
  }

  void _revertAllTitleColors() {
    setState(() {
      nameTitleColor = Colors.black;
      panelPowerTitleColor = Colors.black;
      panelNumberTitleColor = Colors.black;
      maximumVoltageTitleColor = Colors.black;
      tiltTitleColor = Colors.black;
      azimuthTitleColor = Colors.black;
    });
  }

  Future<void> _addInstaltion() async {
    setState(() {
      // Validate all fields and update title colors
      nameTitleColor = nameController.text.isNotEmpty
          ? Colors.black
          : Colors.red;
      panelPowerTitleColor = panelPowerController.text.isNotEmpty
          ? Colors.black
          : Colors.red;
      panelNumberTitleColor = panelNumberController.text.isNotEmpty
          ? Colors.black
          : Colors.red;
      maximumVoltageTitleColor = maximumVoltageController.text.isNotEmpty
          ? Colors.black
          : Colors.red;
      tiltTitleColor = tiltController.text.isNotEmpty
          ? Colors.black
          : Colors.red;
      azimuthTitleColor = azimuthController.text.isNotEmpty
          ? Colors.black
          : Colors.red;
    });

    // Check if any field is invalid
    if ([
      nameTitleColor,
      panelPowerTitleColor,
      panelNumberTitleColor,
      maximumVoltageTitleColor,
      tiltTitleColor,
      azimuthTitleColor,
    ].contains(Colors.red)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all fields")),
      );
      return; // Exit the function if validation fails
    }

    // Add installation data
    await addInstallationData(
      name: nameController.text,
      panelPower: panelPowerController.text,
      panelNumber: panelNumberController.text,
      maximumVoltage: maximumVoltageController.text,
      tilt: tiltController.text,
      azimuth: azimuthController.text,
    );

    // Clear text controllers
    nameController.clear();
    panelPowerController.clear();
    panelNumberController.clear();
    maximumVoltageController.clear();
    tiltController.clear();
    azimuthController.clear();

    // Reset title colors
    _revertAllTitleColors();

    controllerPortal.toggle();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return FPortal(
            controller: controllerPortal,
            spacing: const FPortalSpacing(8),
            viewInsets: const EdgeInsets.all(5),
            portalBuilder: (context) => SizedBox(
              width: constraints.maxWidth,
              child: Container(
                decoration: BoxDecoration(
                  color: context.theme.colors.background,
                  border: Border.all(color: context.theme.colors.border),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: const [
                          Icon(FIcons.plug),
                          SizedBox(width: 8),
                          Text(
                            "Instalation",
                            style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildTextField(
                      "Instaltion name",
                      nameController,
                      "text",
                      nameTitleColor,
                    ),
                    _buildTextField(
                      "Panel Power [kW]",
                      panelPowerController,
                      "decimal",
                      panelPowerTitleColor,
                    ),
                    _buildTextField(
                      "Number of panels",
                      panelNumberController,
                      "integer",
                      panelNumberTitleColor,
                    ),
                    _buildTextField(
                      "Maximum Voltage [V]",
                      maximumVoltageController,
                      "decimal",
                      maximumVoltageTitleColor,
                    ),
                    _buildTextField(
                      "Tilt [degrees]",
                      tiltController,
                      "decimal",
                      tiltTitleColor,
                    ),
                    _buildTextField(
                      "Azimuth [degrees]",
                      azimuthController,
                      "decimal",
                      azimuthTitleColor,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: FButton(
                        onPress: _addInstaltion,
                        child: const Text("Add"),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            child: FButton(
              onPress: controllerPortal.toggle,
              child: Row(
                children: const [
                  Icon(FIcons.zap),
                  SizedBox(width: 10),
                  Text('Add Instalation'),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    String fieldType,
    Color titleColor,
  ) {
    final List<TextInputFormatter> inputFormatters = fieldType == "integer"
        ? [FilteringTextInputFormatter.digitsOnly] // Allow only integers
        : fieldType == "text"
        ? [
            FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]')),
          ] // Allow only letters and spaces
        : [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
          ]; // Allow only decimals
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: FTextField(
        controller: controller,
        label: Text(label, style: TextStyle(color: titleColor)),
        inputFormatters: inputFormatters,
      ),
    );
  }
}

class _HoverableListTile extends StatefulWidget {
  final Map<String, dynamic> doc;
  const _HoverableListTile({required this.doc});

  @override
  State<_HoverableListTile> createState() => _HoverableListTileState();
}

class _HoverableListTileState extends State<_HoverableListTile> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: EdgeInsets.symmetric(
          horizontal: _hovering ? 4 : 8,
          vertical: _hovering ? 2 : 4,
        ),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Theme(
            data: Theme.of(context).copyWith(
              dividerColor: Colors.transparent, // Removes divider lines
              highlightColor:
                  Colors.transparent, // Prevents color change on tap
              splashColor: Colors.transparent, // Prevents ripple effect on tap
              hoverColor: Colors.transparent, // Prevents color change on hover
            ),
            child: ExpansionTile(
              leading: const Icon(FIcons.housePlug),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              collapsedShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              backgroundColor: Colors.transparent, // No background color
              tilePadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              childrenPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      widget.doc['name'],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () async =>
                        await removeInstallationData(widget.doc['docId']),
                  ),
                ],
              ),
              children: [
                _buildInfoRow(
                  FIcons.plugZap,
                  'Power',
                  '${widget.doc['panelPower']} kW',
                ),
                _buildInfoRow(
                  FIcons.columns3,
                  'Panels',
                  '${widget.doc['panelNumber']}',
                ),
                _buildInfoRow(
                  FIcons.zap,
                  'Voltage',
                  '${widget.doc['maximumVoltage']} V',
                ),
                _buildInfoRow(
                  FIcons.arrowRight,
                  'Tilt',
                  '${widget.doc['tilt']}°',
                ),
                _buildInfoRow(
                  FIcons.compass,
                  'Azimuth',
                  '${widget.doc['azimuth']}°',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16),
        const SizedBox(width: 4),
        Text('$label: $value', style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
