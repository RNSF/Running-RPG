import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:running_game/pages/quest_page/view_model.dart';

import '../../theme/theme_constants.dart';

class QuestPage extends StatelessWidget {



  QuestPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var viewModel = QuestPageViewModel(context);
    return ChangeNotifierProvider<QuestPageViewModel>(
      create: (context) => viewModel,
      builder: (context, _) {
        viewModel = Provider.of<QuestPageViewModel>(context);
        return SafeArea(
          child: Scaffold(
            bottomNavigationBar: Material(
               elevation: 10,
               child: Container(
                 width: double.infinity,
                 color: Palette.background3,
                 height: 60,
                 child: Row(children: [
                   Padding(
                     padding: const EdgeInsets.all(8.0),
                     child: IconButton(iconSize: 30, icon: Icon(Icons.arrow_back, color: Theme.of(context).primaryColor), onPressed: () => Navigator.of(context).pop()),
                   )
                 ],)
               ),
            ),
            backgroundColor: Palette.background2,
            body: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    color: Palette.background3,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32.0),
                      child: Column(children: [
                        TitleWidget(title: 'Current Quests'),
                        viewModel.currentQuests.isNotEmpty ? QuestList(
                          quests: viewModel.currentQuests,
                          mainStyle: false,
                          selectedCardIndex: viewModel.selectedCurrentQuestIndex,
                          onTap: viewModel.onCurrentQuestCardTapped,
                          onSelection: viewModel.onCurrentQuestRemoved,
                          onHelp: (int index) => viewModel.onQuestHelpRequested(context, index, true),
                          onQuestRewardClaimed: viewModel.onQuestRewardClaimed,
                        ) : Text("No active quests.", style: Theme.of(context).textTheme.bodySmall?.merge(TextStyle(color: Palette.primary, fontStyle: FontStyle.italic))),
                        SizedBox(height: 32),
                      ],),
                    )
                  ),
                  Container(
                    width: double.infinity,
                    color: Palette.background2,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32.0),
                      child: Column(children: [
                        TitleWidget(title: 'Available Quests'),
                        viewModel.availableQuests.isNotEmpty ? QuestList(
                          quests: viewModel.availableQuests,
                          mainStyle: true, selectedCardIndex:
                          viewModel.selectedAvailableQuestIndex,
                          onTap: viewModel.onAvailableQuestCardTapped,
                          onSelection: viewModel.onAvailableQuestAdded,
                          onHelp: (int index) => viewModel.onQuestHelpRequested(context, index, false),
                          onQuestRewardClaimed: ((int index) {}),
                        ) : Text("No available quests.", style: Theme.of(context).textTheme.bodySmall?.merge(TextStyle(color: Palette.primary, fontStyle: FontStyle.italic))),
                        SizedBox(height: 32),
                      ],),
                    )
                  ),
                ],
              ),
            ),
          )
        );
      }
    );
  }
}


class TitleWidget extends StatelessWidget {

  final String title;

  const TitleWidget({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 8.0,
        vertical: 24.0,
      ),
      child: Text(
        title,
        style: Theme.of(context).textTheme.headlineSmall,
      ),
    );
  }
}


class QuestList extends StatelessWidget {

  List<QuestDisplay> quests;
  bool mainStyle;
  int? selectedCardIndex;
  Function(int) onTap;
  Function(int) onSelection;
  Function(int) onHelp;
  Function(int) onQuestRewardClaimed;

  QuestList({
    Key? key,
    required this.quests,
    this.mainStyle = false,
    this.selectedCardIndex, required
    this.onTap,
    required this.onSelection,
    required this.onHelp,
    required this.onQuestRewardClaimed
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var questStatTextStyle = Theme.of(context).textTheme.bodyMedium?.merge(TextStyle(color: mainStyle ? Palette.background2 : Palette.background3));
    return ListView.builder(
      physics: NeverScrollableScrollPhysics(),
      primary: false,
      shrinkWrap: true,
      itemCount: quests.length,
      itemBuilder: ((context, index) {
        var quest = quests[index];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: (() => quest.isCompleted ? onQuestRewardClaimed(index) : onTap(index)),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5.0),
                side: BorderSide(width: mainStyle ? 0.0 : 4.0, color: quest.isCompleted ? Theme.of(context).primaryColor : Theme.of(context).cardColor),
              ),
              color: mainStyle ? Theme.of(context).cardColor : Color(0x00000000),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(children: [
                  Row(children: [
                    Text(
                      quest.title,
                      style: Theme.of(context).textTheme.headlineSmall?.merge(TextStyle(
                        color: mainStyle ? Palette.background3 : Palette.button,
                      )),
                    ),
                    Expanded(flex: 1, child: SizedBox()),
                    quest.isCompleted ? Icon(Icons.star, color: Theme.of(context).accentColor) : IconButton(
                      onPressed: () => onHelp(index),
                      icon: Icon(Icons.question_mark, color: Theme.of(context).accentColor),
                    )

                  ],),
                  SizedBox(height: 12),
                  DescriptionWidget(quest: quest, style: Theme.of(context).textTheme.bodyMedium?.merge(TextStyle(color: mainStyle ? Palette.background2 : Palette.button))),
                  AnimatedSize(
                    curve: Curves.easeIn,
                    duration: const Duration(milliseconds: 200),
                    child: Container(
                      height: index == selectedCardIndex ? 90 : 0,
                      child: ClipRect(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 12.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  QuestStatWidget(
                                    statName: "Time Limit",
                                    statValue: quest.cleanRemainingTime,
                                    icon: Icons.access_time,
                                    style: mainStyle ? questStatTextStyle : questStatTextStyle?.merge(TextStyle(color: Palette.button)),
                                  ),
                                  QuestStatWidget(
                                    statName: quest.cleanDestinations.contains(",") ? "Destinations" : "Destination",
                                    statValue: quest.cleanDestinations,
                                    icon: Icons.flag,
                                    style: mainStyle ? questStatTextStyle : questStatTextStyle?.merge(TextStyle(color: Palette.button)),
                                  ),
                                  QuestStatWidget(
                                    statName: "Experience",
                                    statValue: quest.cleanXpReward,
                                    icon: Icons.star,
                                    style: mainStyle ? questStatTextStyle : questStatTextStyle?.merge(TextStyle(color: Palette.button)),
                                  ),
                                ],
                              ),
                              Expanded(flex: 1, child: SizedBox()),
                              IconButton(
                                icon: Icon(mainStyle ? Icons.check : Icons.close, color: Theme.of(context).accentColor),
                                iconSize: 32.0,
                                onPressed: () => showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: Text(mainStyle ? "Accept Quest?" : "Cancel Quest?"),
                                    content: Text(mainStyle ?
                                      "Are you sure you would like to accept this quest. It will be added to your quest book, and can be removed later."
                                      : "Are you sure you would like to cancel this quest. You cannot undo this action."),
                                    actions: [
                                      TextButton(
                                        onPressed: () {Navigator.pop(context);},
                                        child: Text("Cancel"),
                                      ),
                                      TextButton(
                                        onPressed: () {onSelection(index); Navigator.pop(context);},
                                        child: Text("Yes")
                                      ),
                                    ]
                                  )
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    ),
                  )
                ],),
              ),
            ),
          ),
        );
      })
    );
  }
}


class QuestStatWidget extends StatelessWidget {

  final String statName;
  final String statValue;
  final IconData icon;
  final TextStyle? style;

  const QuestStatWidget({Key? key, this.statName = "Stat", this.statValue = "10", required this.icon, this.style}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Icon(icon, color: style?.color),
      RichText(
        textAlign: TextAlign.left,
        text: TextSpan(
          style: style,
          children: [
            TextSpan(text: statName + ": "),
            TextSpan(text: statValue, style: TextStyle(fontWeight: FontWeight.bold)),
          ]
        ),
      ),
    ],);
  }
}


class DescriptionWidget extends StatelessWidget {

  final QuestDisplay quest;
  final TextStyle? style;

  const DescriptionWidget({Key? key, required this.quest, required this.style}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var stringSegments = <DescriptionSegment>[DescriptionSegment(text: quest.description, style: style)];
    var replacements = {
      "[location]" : quest.cleanDestinations,
      "[timeLimit]" : quest.cleanRemainingTime,
      "[person]" : quest.questGiver,
    };

    replacements.forEach((itemToReplace, replacement) {
      var stringSegmentsCopy = List<DescriptionSegment>.from(stringSegments);
      stringSegments = [];
      for(var stringSegment in stringSegmentsCopy){
        var splitStrings = stringSegment.text.split(itemToReplace);
        stringSegments.add(DescriptionSegment(text: splitStrings.removeAt(0), style: stringSegment.style));
        for(var subString in splitStrings){
          stringSegments.add(DescriptionSegment(
            text: replacement,
            style: style?.merge(TextStyle(fontWeight: FontWeight.bold)),
          ));
          stringSegments.add(DescriptionSegment(
            text: subString,
            style: style,
          ));
        }
      }
    });

    var textSpans = <TextSpan>[];
    for(var stringSegment in stringSegments){
      textSpans.add(TextSpan(
        text: stringSegment.text,
        style: stringSegment.style,
      ));
    }

    return RichText(
      text: TextSpan(
        children: textSpans,
      ),
    );
  }
}

class DescriptionSegment {
  final String text;
  final TextStyle? style;

  DescriptionSegment({required this.text, required this.style});
}