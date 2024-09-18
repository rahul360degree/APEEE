public class CommonConstants 
{
	public static final Id HOUSEHOLD_RECORDTYPE = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Household').getRecordTypeId();
	public static final Id ORGANISATION_RECORDTYPE = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Organisation').getRecordTypeId();
	public static final Id INSTITUTION_RECORDTYPE = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Paying_Institution').getRecordTypeId();

	public static final Id PARENT_RECORDTYPE = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Parent').getRecordTypeId();
	public static final Id CHILD_RECORDTYPE = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Child').getRecordTypeId();

	public static final String IMPORT_STATUS_NEW = 'New';
	public static final String IMPORT_STATUS_PROCESS = 'Process';
	public static final String IMPORT_STATUS_PROCESSING = 'Processing';
	public static final String IMPORT_STATUS_EXISTS = 'Not processed, already exist';
	public static final String IMPORT_STATUS_SUCCES = 'Success';
	public static final String IMPORT_STATUS_FAILED = 'Failed';
	public static final String IMPORT_STATUS_CLASS_NOT_FOUND = 'Failed, Class not found';
	public static final String IMPORT_STATUS_ENROLLMENT_CREATED = 'Success, Enrollment created';
	public static final String IMPORT_STATUS_STUDENT_CREATED = 'Success, Student Created';
	public static final String IMPORT_STATUS_RETRY = 'Retry';
	public static final String IMPORT_STATUS_HOUSHOLD_UPDATED = 'Success, household address updated	';
	public static final String IMPORT_STATUS_CREATED = 'Success, parent and household created';
	public static final String IMPORT_STATUS_PARENT_CREATED = 'Success, parent created';
	public static final String IMPORT_STATUS_PARENT_NOT_FOUND = 'Failed, parent not found';
	public static final String ENROLLMENT_STATUS_ENROLLED = 'Enrolled';
	public static final String ENROLLMENT_STATUS_UNENROLLED = 'Unenrolled';

	public static final String GENDER_MALE = 'Male';
	public static final String GENDER_FEMALE = 'Female';
	public static final String GENDER_NEUTRAL = 'Neutral';

	public static final String RELATION_FATHER = 'Father';
	public static final String RELATION_MOTHER = 'Mother';
	public static final String RELATION_STEPFATHER = 'Stepfather';
	public static final String RELATION_STEPMOTHER = 'Stepmother';
	public static final String RELATION_DAUGHTER = 'Daughter';
	public static final String RELATION_SON = 'Son';
	public static final String RELATION_NANNY = 'Nanny';
	public static final String RELATION_FAMILY_RELATIVE = 'Family/relative';
	public static final String RELATION_FRIEND = 'Friend';
	public static final String RELATION_UNCLE = 'Uncle';
	public static final String RELATION_ADOPTIVE_PARENTS = 'Adoptive parents';
	public static final String RELATION_COURT_APPOINTED_GUARDIAN = 'Court appointed guardian';
	public static final String RELATION_AUNT = 'Aunt';
	public static final String RELATION_PARTNER = 'Partner';
	public static final String RELATION_GUARDIAN = 'Guardian';
	public static final String RELATION_GRANDMOTHER = 'Grandmother';
	public static final String RELATION_GRANDFATHER = 'Grandfather';
	public static final String RELATION_OTHER = 'Other';

	public static final Map<String, String> relationMapping = new Map<String, String>{
		'father' => RELATION_FATHER,
		'mother' => RELATION_MOTHER,
		'stepfather' => RELATION_STEPFATHER,
		'stepmother' => RELATION_STEPMOTHER,
		'daughter' => RELATION_DAUGHTER,
		'son' => RELATION_SON,
		'nanny' => RELATION_NANNY,
		'familyrelative' => RELATION_FAMILY_RELATIVE,
		'friend' => RELATION_FRIEND,
		'uncle' => RELATION_UNCLE,
		'adoptiveparents' => RELATION_ADOPTIVE_PARENTS,
		'courtappointedguardian' => RELATION_COURT_APPOINTED_GUARDIAN,
		'aunt' => RELATION_AUNT,
		'partner' => RELATION_PARTNER,
		'guardian' => RELATION_GUARDIAN,
		'grandmother' => RELATION_GRANDMOTHER,
		'grandfather' => RELATION_GRANDFATHER,
		'other' => RELATION_OTHER
	};

	public static final Map<String, String> addressKeysByRecordType = new Map<String, String>{
		HOUSEHOLD_RECORDTYPE => 'H',
		ORGANISATION_RECORDTYPE => 'O',
		INSTITUTION_RECORDTYPE => 'I'
	};

	public static final Map<String, String> genderMapping = new Map<String, String>{
		'M' => GENDER_MALE,
		'F' => GENDER_FEMALE,
		'N' => GENDER_NEUTRAL
	};

	public static final Map<String, String> LANGUAGES_BY_CODE = new Map<String,String> {
		'NL' => 'Dutch',
		'EN' => 'English',
		'FI' => 'Finnish',
		'FR' => 'French	',
		'DE' => 'German',
		'IT' => 'Italian',
		'LI' => 'Lithuanian',
		'PT' => 'Portuguese',
		'SV' => 'Swedish'
	};



	public static final Integer DEFAULT_BATCHSIZE = 50;

	public class RuntimeException extends exception {}
}