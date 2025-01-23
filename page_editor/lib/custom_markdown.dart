import 'package:flutter/material.dart';

class CustomMarkdown extends StatelessWidget {
  final String data;

  CustomMarkdown({required this.data});

  @override
  Widget build(BuildContext context) {
    final lines = data.split('\n');
    List<Widget> widgets = [];
    bool tableStarts = false;
    List<String> linesTable = [];

    for (var line in lines) {
      if(line.trim().startsWith("@table") && !tableStarts){
        tableStarts = true;
      }else if(tableStarts){
        if(line.trim().startsWith("@end")){
          tableStarts = false;
          widgets.add(_buildTable(linesTable));
          linesTable = [];
          continue;
        }
        linesTable.add(line);
      }
      else if (line.startsWith("# ") | line.startsWith("## ") | line.startsWith("### ") | line.startsWith("#### ") | line.startsWith("##### ")) {
        final t1 = line.split(" ")[0];
        final t2 = line.substring(t1.length);
        widgets.add(_buildHeader(t2, t1.length));
      } else if (line.startsWith('- ')) {
        widgets.add(_buildListItem(line.substring(2).trim()));
      }
      //  else if (_isTableHeader(line)) {
      //   widgets.add(_buildTable(lines));
      //   break; // Skip the table lines since they are processed together
      // } 
      else {
        widgets.add(_buildParagraph(line.trim()));
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }

  Wrap _formatTextWithWrap(String text) {

    // Split the text based on bold and italic markers
    final children = <Widget>[];

    text.splitMapJoin(
      RegExp(r'\*\*(.*?)\*\*|__(.*?)__|__\*\*(.*?)\*\*__|\*\*__(.*?)__\*\*'),
      onMatch: (match) {
        for(int i=0 ; i<match.groupCount ; i++){
          if(match.group(i) == null) return "";
          if (match.group(i)!.startsWith('__**') || match.group(i)!.startsWith('**__')) {
            children.add(Text(
              match.group(i)!.substring(4,match.group(i)!.length-4),
              style: const TextStyle(fontStyle: FontStyle.italic,fontWeight: FontWeight.w900, fontSize: 16),
            ));
          }else if (match.group(i)!.startsWith('**')) {
            children.add(Text(
              match.group(i)!.substring(2,match.group(i)!.length-2),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ));
          } else if (match.group(i)!.startsWith('__')) {
            children.add(Text(
              match.group(i)!.substring(2,match.group(i)!.length-2),
              style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 16),
            ));
          }
        }
        return ''; // Skip returning matched text
      },
      onNonMatch: (nonMatch) {
        children.add(Text(nonMatch,style: const TextStyle(fontSize: 16),)); // Add plain text
        return ''; // Skip returning unmatched text
      },
    );

    return Wrap(
      spacing: 4.0,
      runSpacing: 4.0,
      children: children,
    );
  }



  Widget _buildHeader(String text, int level) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 24.0 - (level - 1) * 4.0,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildListItem(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('\u2022 '), // Bullet point
        Expanded(
          child: Text(text),
        ),
      ],
    );
  }

  Widget _buildParagraph(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: _formatTextWithWrap(text),
    );
  }

  bool _isTableHeader(String line) {
    return line.contains('|') && RegExp(r'[-]*').hasMatch(line);
  }

  Widget _buildTable(List<String> lines) {
    final rows = lines.map((line) {
      return line.split(';').map((cell) => cell.trim()).toList();
    }).toList();
    return SingleChildScrollView(
      child: Table(
        border: TableBorder.all(color: Colors.black),
        children: [
          TableRow(
            children: rows[0].map((header) => _buildTableCell(header, isHeader: true)).toList(),
          ),
          ...rows.skip(1).map(
            (row) => TableRow(
              children: row.map((cell) => _buildTableCell(cell)).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableCell(String text, {bool isHeader = false}) {
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: !isHeader ?
      Center(child: _formatTextWithWrap(text))
      : 
      Text(
        text,
        style: const TextStyle(
          fontWeight:FontWeight.bold,
          fontSize: 16.0,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
