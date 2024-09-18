public class CurrenTimeController {
     @InvocableMethod()
    public static List<string> getCurrentTime(){
        List<String> currentTime = new List<String>();
        Datetime cDT = System.now();
        currentTime.add(cDT.format('HH:mm a'));
        return currentTime;
    }
    
}