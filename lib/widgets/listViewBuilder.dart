import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Widget listViewBuilder(List<Widget> printing) {
  return Center(
      child: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
              itemCount: printing.length,
              itemBuilder: (BuildContext context, int index) {
                return printing[index];
              },
            ),
          ),
        ],
      )
  );
}