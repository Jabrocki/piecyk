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

class CustomPortal extends StatelessWidget {
  CustomPortal({super.key});

  final controllerPortal = OverlayPortalController();
  final double _textSpacing = 4;

  //Text controllers
  final nameController = TextEditingController();
  final panelPowerController = TextEditingController();
  final panelNumberController = TextEditingController();
  final maximumVoltageController = TextEditingController();
  final tiltController = TextEditingController();
  final azimuthController = TextEditingController();

  Future _addInstaltion() async {
    addInstallationData(
      name: nameController.text, 
      panelPower: panelPowerController.text, 
      panelNumber: panelNumberController.text, 
      maximumVoltage: maximumVoltageController.text, 
      tilt: tiltController.text, 
      azimuth: azimuthController.text
    );
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
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Icon(FIcons.plug),
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
                    _buildTextField("Instaltion name", nameController, "text"),
                    _buildTextField("Panel Power [kW]", panelPowerController, "decimal"),
                    _buildTextField("Number of panels", panelNumberController, "integer"),
                    _buildTextField("Maximum Voltage [V]", maximumVoltageController, "decimal"),
                    _buildTextField("Tilt [degrees]", tiltController, "decimal"),
                    _buildTextField("Azimuth [degrees]", azimuthController, "decimal"),
                    SizedBox(height: _textSpacing),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: FButton(
                        onPress: () {
                          _addInstaltion();
                        }, 
                        child: Text("Add")
                      ),
                    ),
                  ],
                ),
              ),
            ),
            child: FButton(
              onPress: () {
                controllerPortal.toggle();
              },
              child: Row(
                children: [
                  const Icon(FIcons.zap),
                  const SizedBox(width: 10),
                  const Text('Add Instalation'),
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
    String fieldType
  ) {
    final List<TextInputFormatter> inputFormatters = fieldType == "integer"
      ? <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly]
      : fieldType == "decimal"
        ? <TextInputFormatter>[FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))]
        : <TextInputFormatter>[];
    return Column(
      children: [
        SizedBox(height: _textSpacing),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: FTextField(
            controller: controller,
            label: Text(label),
            inputFormatters: inputFormatters,
          ),
        ),
      ],
    );
  }
}

class _HoverableListTile extends StatefulWidget {
  final Map<String, dynamic> doc;
  const _HoverableListTile({Key? key, required this.doc}) : super(key: key);

  @override
  State<_HoverableListTile> createState() => _HoverableListTileState();
}

class _HoverableListTileState extends State<_HoverableListTile> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final double scaleFactor = _hovering ? 1.1 : 1.0;
    final EdgeInsets margin = _hovering
        ? EdgeInsets.zero
        : EdgeInsets.symmetric(horizontal: 8, vertical: 4);
    return MouseRegion(
      onEnter: (_) => setState(() { _hovering = true; }),
      onExit: (_) => setState(() { _hovering = false; }),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        margin: margin,
        transform: Matrix4.identity()..scale(scaleFactor),
        transformAlignment: Alignment.center,
        child: Card(
          margin: EdgeInsets.zero,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: ExpansionTile(
            childrenPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            // Title now includes name and delete button.
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    '${widget.doc['name']}',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () async {
                    await removeInstallationData(widget.doc['docId']);
                  },
                ),
              ],
            ),
            // Additional information is moved into the children.
            children: [
              Row(
                children: [
                  Icon(FIcons.plugZap, size: 16),
                  SizedBox(width: 4),
                  Text('Power: ${widget.doc['panelPower']} kW', style: TextStyle(fontSize: 12)),
                ],
              ),
              Row(
                children: [
                  Icon(FIcons.columns3, size: 16),
                  SizedBox(width: 4),
                  Text('Panels: ${widget.doc['panelNumber']}', style: TextStyle(fontSize: 12)),
                ],
              ),
              Row(
                children: [
                  Icon(FIcons.zap, size: 16),
                  SizedBox(width: 4),
                  Text('Voltage: ${widget.doc['maximumVoltage']} V', style: TextStyle(fontSize: 12)),
                ],
              ),
              Row(
                children: [
                  Icon(FIcons.arrowRight, size: 16),
                  SizedBox(width: 4),
                  Text('Tilt: ${widget.doc['tilt']}°', style: TextStyle(fontSize: 12)),
                ],
              ),
              Row(
                children: [
                  Icon(FIcons.compass, size: 16),
                  SizedBox(width: 4),
                  Text('Azimuth: ${widget.doc['azimuth']}°', style: TextStyle(fontSize: 12)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
