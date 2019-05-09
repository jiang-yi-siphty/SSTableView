# SSTableView

## Overview  
The SSTableView is a TableView build by a scroll view with stack view. Most common APIs are samilar with UITableView. In SSTableView, developer **can embed ViewController in to SSTableViewCell** which is impossible in dynamic UITableViewCell.  

## Orientation
I haven't wrape this SSTableView into module yet. To use it, developer need manually make a StackView embed into a ScrollView like what the demo code does. Then, to use it will be same like using a UITableView and UITableViewCell. However, in SSTableView, developer can embedded a ViewController and its view into the SSTableViewCell.

## TODO  
1. Decouple SSTableView with storyboard or xib.
2. Wrape SSTableView into module as pod 
3. Complish and mock rest UITableView features in SSTableView
