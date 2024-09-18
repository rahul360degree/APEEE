public class CurrentYearController {
	@InvocableMethod()
    public static List<String>  getCurrentYear(){
        List<String> result = new List<String>();
        Integer currentYear = System.now().year();
        String formattedYear = currentYear + '-' + (currentYear + 1);
        result.add(formattedYear);
        return result;
    }
}