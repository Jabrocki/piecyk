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

  // Text controllers
  final nameController = TextEditingController();
  final panelPowerController = TextEditingController();
  final panelNumberController = TextEditingController();
  final maximumVoltageController = TextEditingController();
  final tiltController = TextEditingController();
  final azimuthController = TextEditingController();

  // Error states for each field
  bool nameHasError = false;
  bool panelPowerHasError = false;
  bool panelNumberHasError = false;
  bool maximumVoltageHasError = false;
  bool tiltHasError = false;
  bool azimuthHasError = false;

  @override
  void initState() {
    super.initState();
    // Add listeners to clear all field errors when typing in any field
    nameController.addListener(_clearAllFieldErrors);
    panelPowerController.addListener(_clearAllFieldErrors);
    panelNumberController.addListener(_clearAllFieldErrors);
    maximumVoltageController.addListener(_clearAllFieldErrors);
    tiltController.addListener(_clearAllFieldErrors);
    azimuthController.addListener(_clearAllFieldErrors);
  }

  void _clearAllFieldErrors() {
    if (mounted) {
      setState(() {
        nameHasError = false;
        panelPowerHasError = false;
        panelNumberHasError = false;
        maximumVoltageHasError = false;
        tiltHasError = false;
        azimuthHasError = false;
      });
    }
  }

  Future<void> _addInstaltion() async {
    if (!mounted) return;
    setState(() {
      // Validate all fields and update error states
      nameHasError = nameController.text.isEmpty;
      panelPowerHasError = panelPowerController.text.isEmpty;
      panelNumberHasError = panelNumberController.text.isEmpty;
      maximumVoltageHasError = maximumVoltageController.text.isEmpty;
      tiltHasError = tiltController.text.isEmpty;
      azimuthHasError = azimuthController.text.isEmpty;
    });

    // Check if any field is invalid
    if (nameHasError ||
        panelPowerHasError ||
        panelNumberHasError ||
        maximumVoltageHasError ||
        tiltHasError ||
        azimuthHasError) {
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

    // Reset error states (already handled by listeners, but good for explicit reset)
    _clearAllFieldErrors();

    controllerPortal.toggle();
  }

  @override
  Widget build(BuildContext context) {
    final themeColors = FTheme.of(context).colors;
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
                  color: themeColors.background, // Use theme background
                  border: Border.all(color: themeColors.border), // Use theme border
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Icon(FIcons.plug, color: themeColors.foreground),// Use theme foreground
                          SizedBox(width: 8),
                          Text(
                            "Instalation",
                            style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                              color: themeColors.foreground, // Use theme foreground
                            ),
                          ),
                          Spacer(),
                          FTappable(
                            onPress: controllerPortal.toggle,
                            child: Icon(FIcons.x),
                          ), 
                        ],
                      ),
                    ),
                    _buildTextField(
                      "Instaltion name",
                      nameController,
                      "text",
                      nameHasError,
                      themeColors,
                    ),
                    _buildTextField(
                      "Panel Power [kW]",
                      panelPowerController,
                      "decimal",
                      panelPowerHasError,
                      themeColors,
                    ),
                    _buildTextField(
                      "Number of panels",
                      panelNumberController,
                      "integer",
                      panelNumberHasError,
                      themeColors,
                    ),
                    _buildTextField(
                      "Maximum Voltage [V]",
                      maximumVoltageController,
                      "decimal",
                      maximumVoltageHasError,
                      themeColors,
                    ),
                    _buildTextField(
                      "Tilt [degrees]",
                      tiltController,
                      "decimal",
                      tiltHasError,
                      themeColors,
                    ),
                    _buildTextField(
                      "Azimuth [degrees]",
                      azimuthController,
                      "decimal",
                      azimuthHasError,
                      themeColors,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: FButton(
                        onPress: _addInstaltion,
                        // FButton's child Text will use primaryForeground by default if not specified
                        child: const Text("Add"),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            child: FButton(
              onPress: controllerPortal.toggle,
              // FButton's children (Icon and Text) will use primaryForeground by default
              child: Row(
                mainAxisSize: MainAxisSize.min, // To keep Row compact
                children: const [
                  Icon(FIcons.zap), // Color will be handled by FButton
                  SizedBox(width: 10),
                  Text('Add Instalation'), // Color will be handled by FButton
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
    bool hasError,
    FColors themeColors,
  ) {
    final List<TextInputFormatter> inputFormatters = fieldType == "integer"
        ? [FilteringTextInputFormatter.digitsOnly]
        : fieldType == "text"
        ? [
            FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9\s]')), // Allow letters, numbers, and spaces
          ]
        : [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
          ];
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: FTextField(
        inputFormatters: inputFormatters,
        controller: controller,
        label: Text(label, style: TextStyle(color: hasError ? themeColors.destructive : themeColors.mutedForeground)), // Use mutedForeground for label
        // FTextField text color should be handled by its style or default to foreground
        // If FTextField border needs to change on error, it should be handled internally or via a prop
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
    final themeColors = FTheme.of(context).colors;
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
          color: themeColors.background, // Static color, hover effect from AnimatedContainer margins
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(color: themeColors.border), // Theme border
          ),
          child: Theme( // Keep this Theme to override specific Material defaults if needed
            data: Theme.of(context).copyWith(
              dividerColor: themeColors.background, // Keep or set to Colors.transparent if no dividers needed
              focusColor: Colors.transparent,
              highlightColor: Colors.transparent,
              splashColor: Colors.transparent,
              hoverColor: Colors.transparent,
            ),
            child: ExpansionTile(
              collapsedBackgroundColor: themeColors.background, // Ensure collapsed header background
              leading: Icon(FIcons.housePlug, color: themeColors.primary), // Use primary color for leading icon
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              dense: false,
              collapsedShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              backgroundColor: themeColors.background, // Changed from Colors.transparent
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
                      style: TextStyle(fontWeight: FontWeight.bold, color: themeColors.foreground), // Use theme foreground
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.delete, color: themeColors.destructive), // Use theme destructive
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
                  themeColors,
                ),
                _buildInfoRow(
                  FIcons.columns3,
                  'Panels',
                  '${widget.doc['panelNumber']}',
                  themeColors,
                ),
                _buildInfoRow(
                  FIcons.zap,
                  'Voltage',
                  '${widget.doc['maximumVoltage']} V',
                  themeColors,
                ),
                _buildInfoRow(
                  FIcons.arrowRight,
                  'Tilt',
                  '${widget.doc['tilt']}°',
                  themeColors,
                ),
                _buildInfoRow(
                  FIcons.compass,
                  'Azimuth',
                  '${widget.doc['azimuth']}°',
                  themeColors,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, FColors themeColors) {
    return Padding( // Added padding for better spacing
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        children: [
          Icon(icon, size: 16, color: themeColors.mutedForeground), // Use mutedForeground for info icons
          const SizedBox(width: 8), // Increased spacing
          Text('$label: ', style: TextStyle(fontSize: 12, color: themeColors.mutedForeground, fontWeight: FontWeight.bold)), // Label bold
          Expanded(child: Text(value, style: TextStyle(fontSize: 12, color: themeColors.foreground))), // Value uses foreground
        ],
      ),
    );
  }
}
