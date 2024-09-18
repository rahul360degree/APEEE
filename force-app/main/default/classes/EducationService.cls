public class EducationService 
{

    private ClassesSelector classSelector = (ClassesSelector)Application.Selector.newInstance(Class__c.SObjectType);
    private ClassTypesSelector classTypeSelector = (ClassTypesSelector)Application.Selector.newInstance(ClassType__c.SObjectType);
    private SchoolYearsSelector yearSelector = (SchoolYearsSelector)Application.Selector.newInstance(SchoolYear__c.SObjectType);
    private SchoolsSelector schoolSelector = (SchoolsSelector)Application.Selector.newInstance(School__c.SObjectType);

    private fflib_ISObjectUnitOfWork unitOfWork = Application.UnitOfWork.newInstance();


    public void createClasses(Set<String> classNames, Id schoolId, Id yearId)
    {
        Map<String, Class__c> classesByCode = getClassesByCode(classNames, schoolId, yearId);
        Map<String, ClassType__c> classTypesByCode = getClassTypesByCode(schoolId);

        for (String currentClass : classNames)
        {
            if (null == currentClass)
            {
                continue; // Nothin to do here if we do not have a class code..
            }
            ClassType__c classType = classTypesByCode?.get(getClassType(currentClass));

            if (classesByCode?.containsKey(currentClass))
            {
                system.debug('## Skipping ' + currentClass);
                continue; // Class exists, so do nothing
            }
            else if (null == classType)
            {
                system.debug('## classType does not exist ' + currentClass);
                // ClassType does not exist, so create new one
                classType = constructClassTypeFromCode(currentClass, schoolId);
                unitOfWork.registerNew(classType);
                classTypesByCode.put(getClassType(currentClass), classType);
            }
            // Create new Class Register relationship, don't assign Id, because it might be empty (newly created in this batch)
            system.debug('## Creating ' + currentClass);
            Class__c newClass = constructClassFromCode(currentClass, schoolId, yearId);
            unitOfWork.registerNew(newClass);
            unitOfWork.registerRelationship(newClass, Class__c.Class_Type__c, classType);
        }

        unitOfWork.commitWork();
    }

    private Class__c constructClassFromCode (String classCode, Id schoolId, Id yearId)
    {
        Class__c cclass = new Class__c();
        cclass.Name = classCode;
        cclass.School__c = schoolId;
        cclass.Schoolyear__c = yearId;
        cclass.Class__c = getClass(classCode);
        return cclass;
    }

    private ClassType__c constructClassTypeFromCode(String classCode, Id schoolId)
    {
        ClassType__c classType = new ClassType__c();
        classType.School__c = schoolId;
        classType.Level__c = getLevel(classCode);
        classType.Language__c = Utils.getLanguageFromCode(getLanguageCode(classCode));
        classType.Name = getClassType(classCode);
        return classType;
    }

    private String getClass(String code)
    {
        return code.right(1);
    }

    private String getLevel(String code)
    {
        String typeCode = getClassType(code);
        String level = typeCode.left(typeCode.length()-2);
        return level;
    }

    private String getLanguageCode(String code)
    {
        return getClassType(code).right(2);
    }

    private String getClassType(String code)
    {
        return code.left(code.length()-1);
    }

    private Map<String, SchoolYear__c> yearsByName
    {
        get
        {
            if (null == yearsByName)
            {
                List<SchoolYear__c> years = yearSelector.selectAll();
                for (SchoolYear__c year : years)
                {
                    yearsByName.put(year.Name, year);
                }
            }

            return yearsByName;
        }
        set;
    }

    private Map<String, School__c> schoolsByName
    {
        get
        {
            if (null == schoolsByName)
            {
                List<School__c> schools = schoolSelector.selectAll();
                for (School__c school : schools)
                {
                    schoolsByName.put(school.Name, school);
                }
            }
            
            return schoolsByName;
        }
        set;
    }

    private Map<String,  ClassType__c> getClassTypesByCode(Id schoolId)
    {
        List<ClassType__c> classTypes = classTypeSelector.selectBySchool(schoolId);  // by school!!
        Map<String,ClassType__c> classTypesByCode = new Map<String,ClassType__c>();
        for (ClassType__c currentType : classTypes)
        {
            classTypesByCode.put(currentType.Name, currentType);
        }
        return classTypesByCode;
    }

    private Map<String,Class__c> getClassesByCode(Set<String> classNames, Id schoolId, Id yearId)
    {
        List<Class__c> classes = classSelector.selectByNameSchoolAndYear(classNames, schoolId, yearId);
        Map<String, Class__c> classesByCode = new Map<String, Class__c>();
        
        for (Class__c currentClass : classes)
        {
            classesByCode.put(currentClass.Name, currentClass);
        }
        return classesByCode;
    }
}