# SSTableView

## Overview  
The SSTableView is a TableView build by a scroll view with a stack view.  Most common APIs are similar to UITableView. In SSTableView, the developer can embed a ViewController into the SSTableViewCell which is impossible in dynamic UITableViewCell. 

## Orientation
I haven't wrap this SSTableView into module yet. To use it, the developer need manually make a StackView embed into a ScrollView like what the demo code does. Then, to use it will be the same as using a UITableView and UITableViewCell. However, in SSTableView, the developer can embed a ViewController and its view into the SSTableViewCell.

## TODO  
1. Decouple SSTableView with storyboard or xib.
2. Wrape SSTableView into module as pod 
3. Complish and mock rest UITableView features in SSTableView
