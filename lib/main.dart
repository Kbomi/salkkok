import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final dir = await getApplicationDocumentsDirectory();
  await Hive.initFlutter(dir.path);
  await Hive.openBox('memoBox');
  runApp(SalkkokApp());
}

class SalkkokApp extends StatelessWidget {
  const SalkkokApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: '살꼭', home: MemoTabbedPage());
  }
}

class MemoTabbedPage extends StatefulWidget {
  const MemoTabbedPage({super.key});

  @override
  _MemoTabbedPageState createState() => _MemoTabbedPageState();
}

class _MemoTabbedPageState extends State<MemoTabbedPage> {
  Box? memoBox;
  Map<String, List<String>> memoData = {}; // 장소 : [물건, 물건...]
  final placeController = TextEditingController();
  final itemController = TextEditingController();
  String selectedPlace = '';
  Set<int> selectedItems = {};
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    memoBox = Hive.box('memoBox');
    loadMemoData();
  }

  void loadMemoData() {
    final rawData = memoBox!.toMap();
    memoData = rawData.map(
      (key, value) => MapEntry(key, List<String>.from(value)),
    );
    if (memoData.isNotEmpty) {
      selectedPlace = memoData.keys.first;
    }
    setState(() {});
  }

  void addMemo(String place, String item) {
    place = place.trim();
    item = item.trim();
    if (!memoData.containsKey(place)) {
      memoData[place] = [];
    }
    memoData[place]!.add(item);
    memoBox!.put(place, memoData[place]);
    selectedPlace = place;
    placeController.clear();
    itemController.clear();
    FocusScope.of(context).unfocus();
    setState(() {});
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _scrollToSelectedPlace(),
    );
  }

  void _scrollToSelectedPlace() {
    final index = memoData.keys.toList().indexOf(selectedPlace);
    if (index >= 0 && _scrollController.hasClients) {
      _scrollController.animateTo(
        index * 100.0,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void confirmDeleteItem(String place, int index) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('삭제 확인'),
        content: Text('정말 이 물건을 삭제하시겠어요?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('삭제'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      deleteItem(place, index);
    }
  }

  void confirmDeleteMultipleItems(String place) async {
    if (selectedItems.isEmpty) return;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('선택 항목 삭제'),
        content: Text('선택한 물건들을 정말 삭제하시겠어요?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('삭제'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      deleteSelectedItems(place);
    }
  }

  void deleteItem(String place, int index) {
    memoData[place]!.removeAt(index);
    memoBox!.put(place, memoData[place]);
    setState(() {
      selectedItems.remove(index);
    });
  }

  void deleteSelectedItems(String place) {
    final items = memoData[place]!;
    final toRemove = selectedItems.toList()..sort((a, b) => b.compareTo(a));
    for (var index in toRemove) {
      items.removeAt(index);
    }
    memoBox!.put(place, items);
    setState(() {
      selectedItems.clear();
    });
  }

  void confirmDeletePlace(String place) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('장소 삭제 확인'),
        content: Text('정말 $place 장소와 모든 물품을 삭제하시겠어요?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('삭제'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      deletePlace(place);
    }
  }

  void deletePlace(String place) {
    memoData.remove(place);
    memoBox!.delete(place);
    if (memoData.isNotEmpty) {
      selectedPlace = memoData.keys.first;
    } else {
      selectedPlace = '';
    }
    selectedItems.clear();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final places = memoData.keys.toList();
    final items = selectedPlace.isNotEmpty ? memoData[selectedPlace]! : [];

    return Scaffold(
      appBar: AppBar(
        title: Image.asset('assets/images/logo_appbar.png', height: 36),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: placeController,
                    decoration: InputDecoration(hintText: '(장소)'),
                  ),
                ),
                SizedBox(width: 10),
                Text('에서'),
                SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: itemController,
                    decoration: InputDecoration(hintText: '(물건)'),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    final place = placeController.text.trim();
                    final item = itemController.text.trim();
                    if (place.isNotEmpty && item.isNotEmpty) {
                      addMemo(place, item);
                    }
                  },
                  child: Text(
                    '살거야!',
                    style: TextStyle(color: Colors.blue.shade800),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 8),
          Container(
            height: 48,
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: ListView(
              scrollDirection: Axis.horizontal,
              controller: _scrollController,
              children: places.map((place) {
                final isSelected = selectedPlace == place;
                return Padding(
                  padding: EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(
                      place,
                      style: TextStyle(
                        color: isSelected ? Colors.blue.shade800 : Colors.black,
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: Colors.blue.shade100,
                    checkmarkColor: Colors.blue.shade800,
                    onSelected: (_) {
                      setState(() {
                        selectedPlace = place;
                        selectedItems.clear();
                      });
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16.0, top: 8.0),
            child: Row(
              children: [
                Spacer(), // 왼쪽 공간 확보
                TextButton(
                  onPressed: selectedItems.isEmpty
                      ? null
                      : () => confirmDeleteMultipleItems(selectedPlace),
                  style: TextButton.styleFrom(
                    backgroundColor: selectedItems.isEmpty
                        ? Colors.grey.shade50
                        : Colors.red.shade50,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),

                  child: Text(
                    '선택 삭제',
                    style: TextStyle(
                      color: selectedItems.isEmpty ? Colors.grey : Colors.red,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: selectedPlace.isEmpty
                ? Center(child: Text('장소를 추가해보세요'))
                : Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          itemCount: items.length,
                          itemBuilder: (context, index) {
                            return ListTile(
                              leading: Checkbox(
                                value: selectedItems.contains(index),
                                onChanged: (value) {
                                  setState(() {
                                    if (value == true) {
                                      selectedItems.add(index);
                                    } else {
                                      selectedItems.remove(index);
                                    }
                                  });
                                },
                                activeColor:
                                    Colors.blue.shade400, // 체크됐을 때 테두리와 배경 색
                                checkColor: Colors.white, // 체크 표시 색상
                                fillColor:
                                    WidgetStateProperty.resolveWith<Color>((
                                      states,
                                    ) {
                                      if (states.contains(
                                        WidgetState.selected,
                                      )) {
                                        return Colors
                                            .blue
                                            .shade400; // 선택된 상태일 때 배경
                                      }
                                      return Colors.white; // 기본 배경
                                    }),
                              ),
                              title: Text(items[index]),
                              trailing: IconButton(
                                icon: Icon(
                                  Icons.delete_outline,
                                  color: Colors.red,
                                  size: 20,
                                ),
                                onPressed: () =>
                                    confirmDeleteItem(selectedPlace, index),
                              ),
                            );
                          },
                        ),
                      ),
                      TextButton.icon(
                        icon: Icon(Icons.delete_forever, color: Colors.red),
                        label: Text(
                          '$selectedPlace 삭제',
                          style: TextStyle(color: Colors.red),
                        ),
                        onPressed: () => confirmDeletePlace(selectedPlace),
                      ),
                      SizedBox(height: 16),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
