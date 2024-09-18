public class Application extends fflib_Application
{
	public static final fflib_Application.UnitOfWorkFactory UnitOfWork = 
		new fflib_Application.UnitOfWorkFactory(
				new List<SObjectType> {
					Account.SObjectType, 
					Contact.SObjectType,
					ImportedParent__c.SObjectType,
					ImportedStudent__c.SObjectType,
					ClassType__c.SObjectType,
					Class__c.SObjectType,
					ClassEnrollment__c.SObjectType
				});

	// Configure and create the ServiceFactory for this Application

	public static final fflib_Application.ServiceFactory Service = 
		new fflib_Application.ServiceFactory( 
			new Map<Type, Type> {
					ImportsService.class => ImportsService.class,
					EducationService.class => EducationService.class
	});
	
	// Configure and create the SelectorFactory for this Application
	public static final fflib_Application.SelectorFactory Selector = 
		new fflib_Application.SelectorFactory(
			new Map<SObjectType, Type> {
					Account.SObjectType => AccountsSelector.class,
					Contact.SObjectType => ContactsSelector.class,
					ImportedStudent__c.SObjectType => ImportedStudentsSelector.class,
					ImportedParent__c.SObjectType => ImportedParentsSelector.class,
					Class__c.SObjectType => ClassesSelector.class,
					SchoolYear__c.SObjectType => SchoolYearsSelector.class,
					School__c.SObjectType => SchoolsSelector.class,
					ClassType__c.SObjectType => ClassTypesSelector.class,
					RoutePlan__c.SObjectType => RouteplansSelector.class,
					Busstop__c.SObjectType => BusstopsSelector.class
		});
/*
	// Configure and create the DomainFactory for this Application
	public static final fflib_Application.DomainFactory Domain = 
		new fflib_Application.DomainFactory(
			Application.Selector,
			new Map<SObjectType, Type> {
					<object>.SObjectType => <domainclass>.Constructor.class});
*/
}