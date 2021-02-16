import 'package:creative2/model/ListItem.dart';
import 'package:creative2/model/ToDoList.dart';
import 'package:flutter/material.dart';

class ToDoScreen extends StatefulWidget {
  static const routeName = '/toDoScreen';

  @override
  State<StatefulWidget> createState() {
    return _ToDoState();
  }
}

class _ToDoState extends State<ToDoScreen> {
  ToDoList userList;
  _ToDoController con;

  @override
  void initState() {
    super.initState();
    con = _ToDoController(this);
  }

  void render(func) {
    setState(func);
  }

  @override
  Widget build(BuildContext context) {
    userList = ModalRoute.of(context).settings.arguments;
    List builtHierarchy = con.buildListHierarchy(userList.children, 0);

    return Scaffold(
      appBar: AppBar(
        title: Text('User\'s To-Do List'),
        backgroundColor: Colors.grey[800],
        actions: [
          IconButton(icon: Icon(Icons.add), onPressed: null),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 0.0),
          child: Column(
            children: builtHierarchy,
          ),
        ),
      ),
    );
  }
}

class _ToDoController {
  _ToDoState state;

  _ToDoController(this.state);

  List buildListHierarchy(List<ListItem> children, int indentCount) {
    // iterate through to do list items
    return children
        .map(
          (e) => !e.isFolder
              // placed within row to adjust for slight pixel offset of folder rows
              ? Panel(
                  isFolder: e.isFolder,
                  item: e,
                  toDoCon: this,
                  name: e.name,
                  indentCount:
                      state.userList.children.contains(e) ? 0 : indentCount,
                )
              : // if folder
              //  check if expanded & render accordingly
              // create row with indentation and column with information
              Row(
                  children: [
                    Column(
                      children: [
                        Panel(
                          isFolder: e.isFolder,
                          item: e,
                          name: e.name,
                          toDoCon: this,
                          indentCount: state.userList.children.contains(e)
                              ? 0
                              : indentCount,
                        ),
                        e.isExpanded
                            ? Column(
                                children: buildListHierarchy(
                                    e.children, indentCount + 1),
                              )
                            : SizedBox(height: 0.0, width: 0.0),
                      ],
                    ),
                  ],
                ),
        )
        .toList();
  } // buildListHierarchy

  void toggleExpanded(ListItem item) {
    state.render(() {
      item.isExpanded = !item.isExpanded;
    });
  }

  void addDialog(_PanelState panelState) {
    GlobalKey<FormState> formKey = GlobalKey<FormState>();

    bool isFolder = false;
    String itemName = '';

    showDialog(
      context: state.context,
      barrierDismissible: false,
      builder: (context) {
        bool checkedValue = false;
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            scrollable: true,
            backgroundColor: Colors.grey[200],
            actions: [
              FlatButton(
                onPressed: () => Navigator.pop(state.context),
                color: Colors.grey[800],
                child: Text(
                  'Cancel',
                  style: TextStyle(fontSize: 15.0, color: Colors.white),
                ),
              ),
              FlatButton(
                onPressed: () {
                  if (!formKey.currentState.validate()) return;

                  formKey.currentState.save();

                  state.render(() {
                    state.userList.addItem(
                        isFolder: isFolder,
                        name: itemName,
                        addID: panelState.item.id);
                  });

                  Navigator.pop(context);
                },
                color: Colors.grey[800],
                child: Text(
                  'Add',
                  style: TextStyle(fontSize: 15.0, color: Colors.white),
                ),
              ),
            ],
            content: Form(
              key: formKey,
              child: Column(
                children: [
                  Text(
                    'Name',
                    style: TextStyle(
                      color: Colors.grey[800],
                      fontSize: 15.0,
                    ),
                  ),
                  SizedBox(
                    width: 200.0,
                    child: Theme(
                      data: Theme.of(context)
                          .copyWith(primaryColor: Colors.grey[800]),
                      child: TextFormField(
                        style: TextStyle(color: Colors.grey[800]),
                        decoration: InputDecoration(
                          hintText: 'Groceries, carrots, etc...',
                        ),
                        keyboardType: TextInputType.name,
                        autocorrect: true,
                        onSaved: (String value) {
                          print('save: $value');
                          isFolder = checkedValue;
                          itemName = value;
                        },
                        validator: (String value) {
                          print('validate: $value');
                          if (value.length > 10)
                            return 'Name too long';
                          else
                            return null;
                        },
                      ),
                    ),
                  ),
                  CheckboxListTile(
                    title: Text(
                      'Folder',
                      style: TextStyle(
                        color: Colors.grey[800],
                        fontSize: 20.0,
                      ),
                    ),
                    value: checkedValue,
                    onChanged: (bool value) => setState(() {
                      checkedValue = value;
                    }),
                    checkColor: Colors.grey[800],
                    activeColor: Colors.grey[200],
                  ),
                ],
              ),
            ),
          );
        });
      },
    );
  }

  void addItem(ListItem item) {}

  // void findItem() {}
} // _ToDoController

// custome widget for to do list panels
class Panel extends StatefulWidget {
  // final Widget child;
  final String name;
  final bool isFolder;
  final ListItem item;
  final int indentCount;
  final _ToDoController toDoCon;
  static double indentSize = 50.0;

  Panel({
    @required this.isFolder,
    @required this.item,
    @required this.toDoCon,
    this.name,
    this.indentCount,
  });

  @override
  State<StatefulWidget> createState() {
    return _PanelState();
  }
}

class _PanelState extends State<Panel> {
  ListItem item;
  double screenWidth;
  Color panelColor;
  Color textColor;
  bool checkedValue = false;
  _ToDoController con;

  // for add dialog check box
  bool addDialogCheck = false;

  @override
  void initState() {
    super.initState();
    item = widget.item;
    con = widget.toDoCon;

    // child = widget.child;

    // item = Task(name: 'Task 1', id: 0);
    // item.isExpanded = true;
  }

  void render(func) {
    setState(func);
  }

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    panelColor = item.isFolder ? Colors.grey[600] : Colors.grey[400];
    textColor = item.isFolder ? Colors.white : Colors.grey[800];

    // print('id: ')

    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: Row(
        children: [
          SizedBox(
              width: widget.indentCount == 0
                  ? 0.0
                  : widget.indentCount * Panel.indentSize),
          Container(
            width: screenWidth - (widget.indentCount * Panel.indentSize) - 20,
            height: 50.0,
            decoration: BoxDecoration(
              color: panelColor,
              borderRadius: BorderRadius.circular(7.0),
              // boxShadow: [
              //   BoxShadow(
              //     offset: Offset(5.0, 5.0),
              //     blurRadius: 2.0,
              //     color: Colors.grey[600],
              //   ),
              // ],
            ),
            child: Row(
              children: [
                SizedBox(
                  width: item.isFolder ? 15.0 : 5.0,
                ),
                // Display checkbox if task
                !item.isFolder
                    ? Expanded(
                        flex: 4,
                        child: Transform.scale(
                          scale: 1.5,
                          child: Checkbox(
                            onChanged: (bool value) {
                              setState(() {
                                checkedValue = value;
                              });
                            },
                            value: checkedValue,
                            checkColor: Colors.grey[800],
                            activeColor: panelColor,
                          ),
                        ),
                      )
                    : SizedBox(),
                // Displaying item text
                Expanded(
                  flex: 23,
                  child: Text(
                    widget.name,
                    style: TextStyle(
                      fontSize: 28.0,
                      fontFamily: 'Roboto',
                      color: textColor,
                    ),
                  ),
                ),
                // if item is folder display add icon
                Expanded(
                  flex: 3,
                  child: item.isFolder
                      ? IconButton(
                          icon: Icon(
                            Icons.add,
                            size: 36.0,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            con.addDialog(this);
                          },
                        )
                      : SizedBox(),
                ),
                // if item is folder display drop down icon
                Expanded(
                  flex: 3,
                  child: item.isFolder
                      ? item.isExpanded
                          ? Padding(
                              padding: const EdgeInsets.fromLTRB(
                                  3.0, 0.0, 0.0, 25.0),
                              child: IconButton(
                                icon: Icon(
                                  Icons.expand_more_rounded,
                                  size: 35.0,
                                  color: Colors.white,
                                ),
                                onPressed: () {
                                  con.toggleExpanded(item);
                                },
                              ),
                            )
                          : Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(2.0, 0.0, 0.0, 0.0),
                              child: IconButton(
                                icon: Icon(
                                  Icons.keyboard_arrow_right_rounded,
                                  size: 35.0,
                                  color: Colors.white,
                                ),
                                onPressed: () {
                                  con.toggleExpanded(item);
                                },
                              ),
                            )
                      : SizedBox(),
                ),
                SizedBox(
                  width: 20.0,
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// class _PanelController {
//   _PanelState state;
//   _ToDoController toDoCon;

//   _PanelController(this.state, this.toDoCon);

//   void toggleExpanded() => state.render(() {
//         // toDoCon.state.render(() {
//         //   toDoCon.state.userList = toDoCon.state.userList;
//         // });
//         toDoCon.toggleExpanded(state.item);
//         // state.item.isExpanded = !state.item.isExpanded;
//       });
// }
