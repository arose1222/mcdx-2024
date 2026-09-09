/**
 * @description Controller class for the Egg Manager LWC.
 *              Provides picklist values for Egg Type and Egg Size,
 *              and handles saving Egg__c records.
 * @author      Copado AI
 */
public with sharing class EggManagerController_copado {

    /**
     * @description Returns the picklist values for the Egg_Type__c field.
     * @return List of string values for egg types.
     */
    @AuraEnabled(cacheable=true)
    public static List<String> getEggTypes() {
        List<String> types = new List<String>();
        Schema.DescribeFieldResult fieldResult = Egg__c.Egg_Type__c.getDescribe();
        for (Schema.PicklistEntry entry : fieldResult.getPicklistValues()) {
            if (entry.isActive()) {
                types.add(entry.getLabel());
            }
        }
        return types;
    }

    /**
     * @description Returns the picklist values for the Egg_Size__c field.
     * @return List of string values for egg sizes.
     */
    @AuraEnabled(cacheable=true)
    public static List<String> getEggSizes() {
        List<String> sizes = new List<String>();
        Schema.DescribeFieldResult fieldResult = Egg__c.Egg_Size__c.getDescribe();
        for (Schema.PicklistEntry entry : fieldResult.getPicklistValues()) {
            if (entry.isActive()) {
                sizes.add(entry.getLabel());
            }
        }
        return sizes;
    }

    /**
     * @description Saves a new Egg__c record with the provided field values.
     * @param eggType  The selected egg type.
     * @param eggSize  The selected egg size.
     */
    @AuraEnabled
    public static void saveEggRecord(String eggType, String eggSize) {
        if (!Schema.sObjectType.Egg__c.isCreateable()) {
            throw new AuraHandledException('Insufficient permissions to create Egg records.');
        }
        Egg__c egg = new Egg__c();
        egg.Egg_Type__c = eggType;
        egg.Egg_Size__c = eggSize;
        try {
            insert egg;
        } catch (DmlException e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}