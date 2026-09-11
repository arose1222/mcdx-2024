public with sharing class eggController_copado {

    @AuraEnabled(cacheable=true)
    public static Map<String, List<String>> getPicklistValues() {
        Map<String, List<String>> picklistMap = new Map<String, List<String>>();
        try {
            picklistMap.put('eggTypes', getFieldPicklistValues('Egg__c', 'Egg_Type__c'));
            picklistMap.put('eggSizes', getFieldPicklistValues('Egg__c', 'Egg_Size__c'));
        } catch (Exception ex) {
            System.debug(LoggingLevel.ERROR, 'eggController_copado.getPicklistValues error: ' + ex.getMessage());
            throw new AuraHandledException('Unable to retrieve picklist values: ' + ex.getMessage());
        }
        return picklistMap;
    }

    @AuraEnabled
    public static Id createEggRecord(
        String  eggType,
        String  eggSize,
        Date    dateCollected,
        String  description,
        String  orderName,
        Date    deliveryDate,
        Integer dozensRequested
    ) {
        try {
            if (String.isBlank(eggType)) {
                throw new AuraHandledException('Egg Type is required.');
            }
            if (String.isBlank(eggSize)) {
                throw new AuraHandledException('Egg Size is required.');
            }
            if (dateCollected != null && dateCollected > Date.today()) {
                throw new AuraHandledException('Date Collected cannot be in the future.');
            }
            if (String.isBlank(orderName)) {
                throw new AuraHandledException('Order Name is required.');
            }
            if (deliveryDate != null && deliveryDate < Date.today()) {
                throw new AuraHandledException('Delivery Date cannot be in the past.');
            }
            if (dozensRequested != null && dozensRequested <= 0) {
                throw new AuraHandledException('Dozens Requested must be greater than zero.');
            }

            Egg__c newEgg = new Egg__c(
                Egg_Type__c         = eggType,
                Egg_Size__c         = eggSize,
                Date_Collected__c   = dateCollected,
                Description__c      = description,
                Active__c           = true,
                Order_Name__c       = orderName,
                Delivery_Date__c    = deliveryDate,
                Dozens_Requested__c = dozensRequested
            );
            insert newEgg;
            return newEgg.Id;

        } catch (AuraHandledException ex) {
            throw ex;
        } catch (Exception ex) {
            System.debug(LoggingLevel.ERROR, 'eggController_copado.createEggRecord error: ' + ex.getMessage());
            throw new AuraHandledException('Unable to create Egg record: ' + ex.getMessage());
        }
    }

    private static List<String> getFieldPicklistValues(String objectName, String fieldName) {
        List<String> values = new List<String>();
        Schema.SObjectType sObjType = Schema.getGlobalDescribe().get(objectName);
        if (sObjType == null) { return values; }
        Map<String, Schema.SObjectField> fieldMap = sObjType.getDescribe().fields.getMap();
        if (!fieldMap.containsKey(fieldName.toLowerCase())) { return values; }
        for (Schema.PicklistEntry entry : fieldMap.get(fieldName.toLowerCase()).getDescribe().getPicklistValues()) {
            if (entry.isActive()) { values.add(entry.getValue()); }
        }
        return values;
    }
}