public with sharing class ImportsService 
{
	private AccountsSelector accountSelector = (AccountsSelector)Application.Selector.newInstance(Account.SObjectType);
	private ContactsSelector contactSelector = (ContactsSelector)Application.Selector.newInstance(Contact.SObjectType);
	private ImportedParentsSelector parentsSelector = (ImportedParentsSelector)Application.Selector.newInstance(ImportedParent__c.SObjectType);
	private ClassesSelector classSelector = (ClassesSelector)Application.Selector.newInstance(Class__c.SObjectType);

	private fflib_ISObjectUnitOfWork unitOfWork;

	@TestVisible
	private ImportsService(fflib_ISObjectUnitOfWork unitOfWork) 
	{
		this.unitOfWork = unitOfWork;
  }

	public ImportsService() 
	{
		// We don't do this at construction time because of serialization errors
		// this.unitOfWork = Application.UnitOfWork.newInstance();
	}


	private String getUniqueKeyForParent (ImportedParent__c parent)
	{
		return (null == parent.Parent_Id__c) ? parent.Email__c : parent.Parent_Id__c;
	}

	public void processParents(List<ImportedParent__c> parents)
	{
		if (null == this.unitOfWork)
		{
			this.unitOfWork = Application.UnitOfWork.newInstance();
		}

		Map<String, Account> newAccountsByKey = new Map<String, Account>();

		Map<String, ParentWrapper> parentsByKey = new Map<String, ParentWrapper>();
		Set<String> emailAddresses = new Set<String>();
		Set<String> addressKeys = new Set<String>();

		for (ImportedParent__c currentParent : parents)
		{
			ParentWrapper wrapper = new ParentWrapper(currentParent);
			String uniqueKey = getUniqueKeyForParent(currentParent);

			if (null == uniqueKey)
			{
				persistImportStatus(currentParent, CommonConstants.IMPORT_STATUS_FAILED);
				continue;  // Continue with next parent
			}

			parentsByKey.put(uniqueKey, wrapper);

			emailAddresses.add(currentParent.Email__c);
			addressKeys.add(wrapper.addressKey);
		}
		Map<String, Contact> existingContactsByKey = contactSelector.selectByKeyValues(parentsByKey.keySet(), emailAddresses, CommonConstants.PARENT_RECORDTYPE);

		for (Contact thisContact : existingContactsByKey.values()) // Make sure we also query currently assigned Account records
		{
			addressKeys.add(thisContact.Account.UniqueAddressKey__c);
		}

		Map<String, Account> existingAccountsByKey = accountSelector.selectByAddressKeyAndRecordtype(addressKeys, CommonConstants.HOUSEHOLD_RECORDTYPE);
		Map<Id, Account> existingAccountsById = new Map<Id, Account>(existingAccountsByKey.values());

		Map<String, Account> createdAccountsByKey = new Map<String, Account>();
		Map<String, Contact> createdContactsByKey = new Map<String, Contact>();

		for (ImportedParent__c currentParent : parents)
		{
			String currentKey = getUniqueKeyForParent(currentParent);
			ParentWrapper currentWrapper = parentsByKey.get(currentKey);
			String currentParentId = currentParent.Parent_Id__c;
			String currentEmail = currentParent.Email__c;

			Contact contactToUpdate = null;

			if ((currentParentId != null && createdContactsByKey.containsKey(currentParentId)) || createdContactsByKey.containsKey(currentEmail))
			{
				persistImportStatus(currentParent, CommonConstants.IMPORT_STATUS_EXISTS);

				Contact createdContact = (Contact) (createdContactsByKey.containsKey(currentParentId) ? createdContactsByKey.get(currentParentId) : createdContactsByKey.get(currentEmail));
				unitOfWork.registerRelationship(currentParent, ImportedParent__c.Contact__c, createdContact);

				continue;  // Parent already handled in this batch chunck, so we can skip this record entirely (Parent are in the dataset multiple times when they have multiple children)
			}

			//If we cannot find parent by Id, try by email..
			Contact existingContact = (!existingContactsByKey.containsKey(currentParentId))? existingContactsByKey.get(currentEmail) : existingContactsByKey.get(currentParentId);

			if (null != existingContact && null == existingContact.School_Contact_ID__c)
			{
				existingContact.School_Contact_ID__c = currentParentId;
				contactToUpdate = existingContact;
			}

			if (null != existingContact)		// Parent exists 
			{
				system.debug('Parent exists : ' + existingContact + '(' + currentParent.Id + ')');
				if (existingAccountsById.containsKey(existingContact.AccountId))		// Parent has household account
				{
					Account existingAccount = existingAccountsById.get(existingContact.AccountId);
					system.debug('Existing Account : ' + existingAccount);				


					/* Disabled modification of Account records for now, existing Account information in SF is Leading for now*/
					// if (existingAccount?.UniqueAddressKey__c == currentWrapper.addressKey)		// Has correct account
					// {
						unitOfWork.registerRelationship(currentParent, ImportedParent__c.Contact__c, existingContact);
						persistImportStatus(currentParent, CommonConstants.IMPORT_STATUS_EXISTS);
					// }
					// else		// Not the right account, get existing or create new one..
					// {
					// 	existingAccount = existingAccountsByKey.get(currentWrapper.addressKey);
					// 	if (null != existingAccount)		// Get existing
					// 	{
					// 		existingContact.AccountId = existingAccount.Id;
					// 		contactToUpdate = existingContact;
					// 		persistImportStatus(currentParent, CommonConstants.IMPORT_STATUS_HOUSHOLD_UPDATED);
					// 	}
					// 	else	// Create new account
					// 	{
					// 		assignNewAccountToParent(currentParent, createdAccountsByKey, currentWrapper, existingContact, CommonConstants.IMPORT_STATUS_HOUSHOLD_UPDATED);
					// 		contactToUpdate = existingContact;
					// 	}
					// }
				}
				else
				{
					assignNewAccountToParent(currentParent, createdAccountsByKey, currentWrapper, existingContact, CommonConstants.IMPORT_STATUS_CREATED);
					contactToUpdate = existingContact;
				}
				if (null != contactToUpdate)
				{
					unitOfWork.registerRelationship(currentParent, ImportedParent__c.Contact__c, contactToUpdate);
					unitOfWork.registerDirty(contactToUpdate);
				}
			}
			else		//Parent does not exist
			{
				Contact newContact = mapParentToContact(currentParent);
				unitOfWork.registerRelationship(currentParent, ImportedParent__c.Contact__c, newContact);				
				unitOfWork.registerNew(newContact);
				createdContactsByKey.put(currentKey, newContact);

				Account existingAccount = existingAccountsByKey.get(currentWrapper?.addressKey);
				if (null != existingAccount)		// Get existing account
				{
					newContact.AccountId = existingAccount.Id;
					persistImportStatus(currentParent, CommonConstants.IMPORT_STATUS_PARENT_CREATED);
				}
				else	// Create new account
				{
					assignNewAccountToParent(currentParent, createdAccountsByKey, currentWrapper, newContact, CommonConstants.IMPORT_STATUS_CREATED);
				}
				system.debug('New Contact : ' + newContact);
			}
		}
		//TODO: handle duplicate errors gracefully?
		unitOfWork.commitWork();
	}

	private void assignNewAccountToParent(ImportedParent__c parent, 
			Map<String, Account> createdAccountsByKey,
			ParentWrapper wrapper,
			Contact parentContact,
			String status)
	{
		if (!createdAccountsByKey.containsKey(wrapper?.addressKey))
		{
			Account newAccount = mapParentToAccount(parent);
			createdAccountsByKey.put(wrapper?.addressKey, newAccount);
			unitOfWork.registerNew(newAccount);
			unitOfWork.registerRelationship(parentContact, Contact.AccountId, newAccount);
			persistImportStatus(parent, status);
			system.debug('New Account : ' + newAccount);

		}
		else
		{
			Account newAccount = createdAccountsByKey.get(wrapper?.addressKey);
			unitOfWork.registerRelationship(parentContact, Contact.AccountId, newAccount);
			persistImportStatus(parent, status);
			system.debug('New Account (ready made): ' + newAccount);
		}
	}

	public void processStudents(List<ImportedStudent__c> students)
	{

		if (null == students)
		{
			throw new CommonConstants.RuntimeException('Cannot process without list of students');
		}

		if (null == this.unitOfWork)
		{
			this.unitOfWork = Application.UnitOfWork.newInstance();
		}

		Set<String> studentIds = new Set<String>();
		Set<String> emailAddresses = new Set<String>();
		Set<String> classCodes = new Set<String>();
		String currentSchoolYear = students[0].School_Year__c;
		String currentSchool = students[0].School__c;

		Map<String,ImportedParent__c> parentsByStudentId = new Map<String, ImportedParent__c>();

		for (ImportedStudent__c currentStudent : students)
		{
			studentIds.add(currentStudent.Student_ID__c);
			emailAddresses.add(currentStudent.Email__c);
			classCodes.add(currentStudent.Class_code__c);
		}

		List<ImportedParent__c> parents = parentsSelector.getByExternalStudentId(studentIds);
		Map<String, Contact> existingStudents = contactSelector.selectByKeyValues(studentIds, emailAddresses, CommonConstants.CHILD_RECORDTYPE);
		List<Class__c> relevantClasses = classSelector.selectByNameSchoolAndYear(classCodes, currentSchool, currentSchoolYear);
		Map<String, Class__c> classesByCode = getClassesMap(relevantClasses);

		for (ImportedParent__c currentParent : parents)
		{
			parentsByStudentId.put(currentParent.Student_ID__c, currentParent);
		}

		for (ImportedStudent__c currentStudent : students)
		{
			ImportedParent__c currentParent = parentsByStudentId.get(currentStudent.Student_ID__c);
			if (null == currentParent)
			{
				persistImportStatus(currentStudent, CommonConstants.IMPORT_STATUS_PARENT_NOT_FOUND);
				continue;
			}

			Contact studentContact;
			String currentStudentId  = currentStudent.Student_ID__c;
			String classUniqueId = currentStudent.School__c + currentStudent.Class_code__c;
			Class__c currentClass = classesByCode.get(classUniqueId);

			if (existingStudents.containsKey(currentStudent.Student_ID__c) || existingStudents.containsKey(currentStudent.Email__c)) // Student exists
			{
				studentContact = (existingStudents.containsKey(currentStudent.Student_ID__c) ? existingStudents.get(currentStudent.Student_ID__c): existingStudents.get(currentStudent.Email__c));
				if (null == studentContact.School_Contact_ID__c)
				{
					studentContact.School_Contact_ID__c = currentStudent.Student_ID__c;
					unitOfWork.registerDirty(studentContact);
				}
				if (null == currentStudent.Contact__c)
				{
					currentStudent.Contact__c = studentContact.Id;
					unitOfWork.registerDirty(currentStudent);
				}
				if (null != currentClass)
				{
					ClassEnrollment__c existingEnrollment;

					// TODO: Make sure only 1 enrollment per year/school. Overwrite existing
					if (studentContact.Class_Enrollments__r?.size() > 0)
					{
						for (ClassEnrollment__c enrollment : studentContact.Class_Enrollments__r)
						{
							if (enrollment.Class__c == currentClass.Id || (enrollment.School_Year__c == currentSchoolYear && enrollment.Class_Type__r.School__c == currentSchool))
							{
								existingEnrollment = getEnrollment(currentStudent, currentClass, studentContact.Id);
								existingEnrollment.Id = enrollment.Id;
								unitOfWork.registerDirty(existingEnrollment);
								break;
							}
						}
					}

					if (null == existingEnrollment)
					{
						ClassEnrollment__c enrollment = getEnrollment(currentStudent, currentClass, studentContact.Id);
						persistImportStatus(currentStudent, CommonConstants.IMPORT_STATUS_ENROLLMENT_CREATED);
						unitOfWork.registerNew(enrollment);
					}
					else
					{
						persistImportStatus(currentStudent, CommonConstants.IMPORT_STATUS_ENROLLMENT_CREATED);  // TODO: Different status for existing enrollment?
					}
				}
				else
				{
					persistImportStatus(currentStudent, CommonConstants.IMPORT_STATUS_CLASS_NOT_FOUND);
				}
			}
			else // Student doesn't exist
			{
				studentContact = mapStudentToContact(currentStudent);
				studentContact.AccountId = currentParent.Contact__r?.AccountId;
				unitOfWork.registerNew(studentContact);
				unitOfWork.registerRelationship(currentStudent, ImportedStudent__c.Contact__c, studentContact);

				ClassEnrollment__c enrollment = getEnrollment(currentStudent, currentClass, null);
				unitOfWork.registerNew(enrollment);
				unitOfWork.registerRelationship(enrollment, ClassEnrollment__c.Contact__c, studentContact);
				persistImportStatus(currentStudent, CommonConstants.IMPORT_STATUS_STUDENT_CREATED);
			}

		}

		unitOfWork.commitWork();
	}

	private ClassEnrollment__c getEnrollment(ImportedStudent__c student, Class__c clas, Id contactId)
	{
		return new ClassEnrollment__c(
			Contact__c = contactId,
			Status__c = CommonConstants.ENROLLMENT_STATUS_ENROLLED,
			Class__c = clas.Id,
			School_Year__c = student.School_Year__c,
			Class_Type__c = clas.Class_Type__c
		);
	}

	private Map<String, Class__c> getClassesMap(List<Class__c> classes)
	{
		Map<String, Class__c> classesByUniqueKey = new Map<String, Class__c>();

		for (Class__c currentClass : classes)
		{
			String uniqueKey = currentClass.School__c + currentClass.Name;
			classesByUniqueKey.put(uniqueKey, currentClass);
		}

		return classesByUniqueKey;
	}

	private void persistImportStatus(SObject objectToPersist, String status)
	{
		objectToPersist.put('Import_status__c', status);
		unitOfWork.registerDirty(objectToPersist);
	}


	// private void persistImportStatus(ImportedParent__c parent, String status)
	// {
	// 	parent.Import_status__c = status;
	// 	unitOfWork.registerDirty(parent);
	// }

	private Account mapParentToAccount(ImportedParent__c parent)
	{
		Account newAccount = new Account();
		newAccount.Name = String.format('{0} | {1} | {2}', new List<Object>{parent.Surname__c, parent.City__c, parent.Postalcode__c});
		newAccount.ShippingStreet = parent.Street__c;
		newAccount.ShippingCity = parent.City__c;
		newAccount.ShippingCountry = parent.Country__c;
		newAccount.ShippingPostalCode = parent.Postalcode__c;
		newAccount.RecordTypeId = CommonConstants.HOUSEHOLD_RECORDTYPE;
		return newAccount;
	}

	private Contact mapParentToContact(ImportedParent__c parent)
	{
		Contact c = new Contact();
		c.FirstName = parent.Firstname__c;
		c.LastName = parent.Surname__c;
		c.Email = parent.Email__c;
		c.IBAN__c = parent.IBAN__c;
		c.Second_email__c = parent.Second_email__c;
		c.MobilePhone = parent.Mobile__c;
		c.HomePhone = parent.Home_Phone__c;
		c.Phone = parent.Work_Phone__c;
		c.RecordTypeId = CommonConstants.PARENT_RECORDTYPE;
		c.School_Contact_ID__c = parent.Parent_Id__c;
		c.Relationship__c = Utils.getNormalizedRelation(parent.Relationship__c); // Make sure 'Steph father' and 'Stepfather' both result in the same picklist value
		return c;
	}

	private Contact mapStudentToContact(ImportedStudent__c student)
	{
		Contact c = new Contact();
		c.RecordTypeId = CommonConstants.CHILD_RECORDTYPE;
		c.FirstName = student.Firstname__c;
		c.LastName = student.Surname__c;
		c.School_Contact_ID__c = student.Student_ID__c;
		c.Birthdate = student.Birthdate__c;
		c.Gender__c = Utils.getNormalizedGender(student.Gender__c);
		c.Email = student.Email__c;
		c.Card_ID__c = student.Card_ID__c;
		return c;
		/*
			ImportedStudent__c.Class_code__c,
			ImportedStudent__c.Enrolment_Date__c,
			ImportedStudent__c.School__c,
			ImportedStudent__c.School_Year__c,
			ImportedStudent__c.Import_status__c,
			ImportedStudent__c.PerNum__c 
		*/
	}

	private class ParentWrapper 
	{
		public ImportedParent__c parent;
		public String addressKey;
		public String parentId;
		public String email;

		public ParentWrapper(ImportedParent__c parent)
		{
			this.parent = parent;
			this.addressKey = Utils.getUniqueAddressKey(parent);
			this.parentId = parent.Parent_Id__c;
			this.email = parent.Email__c;
		}
	}
}