@IsTest
private class eggControllerTest_copado {

    @TestSetup
    static void setupTestData() {
        insert new Egg__c(
            Egg_Type__c       = 'Chicken',
            Egg_Size__c       = 'Large',
            Date_Collected__c = Date.today(),
            Active__c         = true,
            Order_Name__c     = 'Test Order'
        );
    }

    @IsTest
    static void testGetPicklistValues_success() {
        Test.startTest();
        Map<String, List<String>> result = eggController_copado.getPicklistValues();
        Test.stopTest();
        System.assertNotEquals(null, result, 'Result should not be null');
        System.assert(result.containsKey('eggTypes'), 'Should contain eggTypes');
        System.assert(result.containsKey('eggSizes'), 'Should contain eggSizes');
        System.assert(!result.get('eggTypes').isEmpty(), 'eggTypes should not be empty');
        System.assert(!result.get('eggSizes').isEmpty(), 'eggSizes should not be empty');
    }

    @IsTest
    static void testCreateEggRecord_success() {
        Test.startTest();
        Id eggId = eggController_copado.createEggRecord(
            'Duck', 'Medium', Date.today(), 'A fresh duck egg',
            'Order Alpha', Date.today().addDays(3), 2
        );
        Test.stopTest();
        System.assertNotEquals(null, eggId, 'Egg Id should not be null');
        Egg__c created = [SELECT Egg_Type__c, Egg_Size__c, Active__c, Order_Name__c,
                                 Delivery_Date__c, Dozens_Requested__c
                          FROM Egg__c WHERE Id = :eggId];
        System.assertEquals('Duck',                    created.Egg_Type__c);
        System.assertEquals('Medium',                  created.Egg_Size__c);
        System.assertEquals(true,                      created.Active__c);
        System.assertEquals('Order Alpha',             created.Order_Name__c);
        System.assertEquals(Date.today().addDays(3),   created.Delivery_Date__c);
        System.assertEquals(2, (Integer) created.Dozens_Requested__c);
    }

    @IsTest
    static void testCreateEggRecord_withAllNewFields() {
        Test.startTest();
        Id eggId = eggController_copado.createEggRecord(
            'Turkey', 'Small', Date.today(), 'Turkey egg order',
            'Order Beta', Date.today().addDays(7), 5
        );
        Test.stopTest();
        Egg__c egg = [SELECT Order_Name__c, Delivery_Date__c, Dozens_Requested__c FROM Egg__c WHERE Id = :eggId];
        System.assertEquals('Order Beta',            egg.Order_Name__c);
        System.assertEquals(Date.today().addDays(7), egg.Delivery_Date__c);
        System.assertEquals(5, (Integer) egg.Dozens_Requested__c);
    }

    @IsTest
    static void testCreateEggRecord_nullOptionalNewFields() {
        Test.startTest();
        Id eggId = eggController_copado.createEggRecord(
            'Goose', 'Large', Date.today(), null,
            'Order Gamma', null, null
        );
        Test.stopTest();
        Egg__c egg = [SELECT Order_Name__c, Delivery_Date__c, Dozens_Requested__c FROM Egg__c WHERE Id = :eggId];
        System.assertEquals('Order Gamma', egg.Order_Name__c);
        System.assertEquals(null,          egg.Delivery_Date__c);
        System.assertEquals(null,          egg.Dozens_Requested__c);
    }

    @IsTest
    static void testCreateEggRecord_noDescription() {
        Test.startTest();
        Id eggId = eggController_copado.createEggRecord(
            'Duck', 'Small', Date.today(), null,
            'Order Delta', null, null
        );
        Test.stopTest();
        System.assertNotEquals(null, eggId);
        Egg__c egg = [SELECT Description__c FROM Egg__c WHERE Id = :eggId];
        System.assertEquals(null, egg.Description__c);
    }

    @IsTest
    static void testExpirationDate_setOnCreateViaController() {
        Date collected = Date.today().addDays(-2);
        Test.startTest();
        Id eggId = eggController_copado.createEggRecord(
            'Chicken', 'Large', collected, null, 'Order Exp', null, null
        );
        Test.stopTest();
        Egg__c egg = [SELECT Expiration_Date__c FROM Egg__c WHERE Id = :eggId];
        System.assertEquals(collected.addDays(13), egg.Expiration_Date__c,
            'Expiration should be 13 days after Date Collected');
    }

    @IsTest
    static void testExpirationDate_recalculatedWhenDateCollectedChanges() {
        Egg__c egg = [SELECT Id, Date_Collected__c, Expiration_Date__c FROM Egg__c LIMIT 1];
        System.assertEquals(egg.Date_Collected__c.addDays(13), egg.Expiration_Date__c,
            'Initial expiration should be Date Collected + 13');
        Date newDate = Date.today().addDays(-5);
        Test.startTest();
        egg.Date_Collected__c = newDate;
        update egg;
        Test.stopTest();
        Egg__c updated = [SELECT Expiration_Date__c FROM Egg__c WHERE Id = :egg.Id];
        System.assertEquals(newDate.addDays(13), updated.Expiration_Date__c,
            'Expiration should be recalculated when Date Collected changes');
    }

    @IsTest
    static void testCreateEggRecord_blankEggType() {
        Boolean thrown = false;
        Test.startTest();
        try {
            eggController_copado.createEggRecord('', 'Large', Date.today(), 'Test', 'Order X', null, null);
        } catch (AuraHandledException ex) { thrown = true; }
        Test.stopTest();
        System.assert(thrown, 'Should throw for blank Egg Type');
    }

    @IsTest
    static void testCreateEggRecord_blankEggSize() {
        Boolean thrown = false;
        Test.startTest();
        try {
            eggController_copado.createEggRecord('Chicken', '', Date.today(), 'Test', 'Order X', null, null);
        } catch (AuraHandledException ex) { thrown = true; }
        Test.stopTest();
        System.assert(thrown, 'Should throw for blank Egg Size');
    }

    @IsTest
    static void testCreateEggRecord_nullDateCollected() {
        Boolean thrown = false;
        Test.startTest();
        try {
            eggController_copado.createEggRecord('Chicken', 'Large', null, 'Test', 'Order X', null, null);
        } catch (AuraHandledException ex) { thrown = true; }
        Test.stopTest();
        System.assert(thrown, 'Should throw for null Date Collected');
    }

    @IsTest
    static void testCreateEggRecord_futureDate() {
        Boolean thrown = false;
        Test.startTest();
        try {
            eggController_copado.createEggRecord('Goose', 'Large', Date.today().addDays(5), 'Future', 'Order X', null, null);
        } catch (AuraHandledException ex) { thrown = true; }
        Test.stopTest();
        System.assert(thrown, 'Should throw for future date collected');
    }

    @IsTest
    static void testCreateEggRecord_blankOrderName() {
        Boolean thrown = false;
        Test.startTest();
        try {
            eggController_copado.createEggRecord('Chicken', 'Large', Date.today(), 'Test', '', null, null);
        } catch (AuraHandledException ex) { thrown = true; }
        Test.stopTest();
        System.assert(thrown, 'Should throw for blank Order Name');
    }

    @IsTest
    static void testCreateEggRecord_pastDeliveryDate() {
        Boolean thrown = false;
        Test.startTest();
        try {
            eggController_copado.createEggRecord('Chicken', 'Large', Date.today(), 'Test', 'Order X', Date.today().addDays(-1), null);
        } catch (AuraHandledException ex) { thrown = true; }
        Test.stopTest();
        System.assert(thrown, 'Should throw for past Delivery Date');
    }

    @IsTest
    static void testCreateEggRecord_zeroDozensRequested() {
        Boolean thrown = false;
        Test.startTest();
        try {
            eggController_copado.createEggRecord('Chicken', 'Large', Date.today(), 'Test', 'Order X', null, 0);
        } catch (AuraHandledException ex) { thrown = true; }
        Test.stopTest();
        System.assert(thrown, 'Should throw for zero Dozens Requested');
    }

    @IsTest
    static void testCreateEggRecord_negativeDozensRequested() {
        Boolean thrown = false;
        Test.startTest();
        try {
            eggController_copado.createEggRecord('Chicken', 'Large', Date.today(), 'Test', 'Order X', null, -5);
        } catch (AuraHandledException ex) { thrown = true; }
        Test.stopTest();
        System.assert(thrown, 'Should throw for negative Dozens Requested');
    }

    @IsTest
    static void testCreateEggRecord_bulk() {
        List<Egg__c> eggs = new List<Egg__c>();
        for (Integer i = 0; i < 200; i++) {
            eggs.add(new Egg__c(
                Egg_Type__c       = 'Turkey',
                Egg_Size__c       = 'Large',
                Date_Collected__c = Date.today(),
                Active__c         = true,
                Order_Name__c     = 'Bulk Order ' + i
            ));
        }
        Test.startTest();
        insert eggs;
        Test.stopTest();
        System.assertEquals(200, [SELECT COUNT() FROM Egg__c WHERE Egg_Type__c = 'Turkey']);
        Date expected = Date.today().addDays(13);
        System.assertEquals(200, [SELECT COUNT() FROM Egg__c
                                  WHERE Egg_Type__c = 'Turkey' AND Expiration_Date__c = :expected]);
    }
}