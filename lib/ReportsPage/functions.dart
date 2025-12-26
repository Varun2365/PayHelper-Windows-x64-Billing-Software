String currentYear(){
  return DateTime.now().year.toString();
}
String currentMonth(){
 var temp = DateTime.now().month.toString();
 if(temp.length == 1){
  temp = "0$temp";
 }
 return temp;
}
String currentDay(){
  var temp = DateTime.now().day.toString();
  if(temp.length == 1){
    temp = "0$temp";
  }
  return temp;
}