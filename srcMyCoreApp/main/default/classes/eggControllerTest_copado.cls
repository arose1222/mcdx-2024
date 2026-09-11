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

    // ── Picklist ──────────────────────────────────────────────────────────────

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

    // ── createEggRecord - success paths ───────────────────────────────────────

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
    static void testCreateEggRecord_noDescription() {
        Test.startTest();
        Id eggId = eggController_copado.createEggRecord('Quail', 'Peewee', Date.today(), null);
        Test.stopTest();
        System.assertNotEquals(null, eggId);
        Egg__c egg = [SELECT Description__c FROM Egg__c WHERE Id = :eggId];
        System.assertEquals(null, egg.Description__c);
    }

    @IsTest
    static void testCreateEggRecord_blankEggType() {
        Boolean thrown = false;
        Test.startTest();
        try { eggController_copado.createEggRecord('', 'Large', Date.today(), 'Test'); }
        catch (AuraHandledException ex) { thrown = true; }
        Test.stopTest();
        System.assert(thrown, 'Should throw for blank Egg Type');
    }

    @IsTest
    static void testCreateEggRecord_blankEggSize() {
        Boolean thrown = false;
        Test.startTest();
        try { eggController_copado.createEggRecord('Chicken', '', Date.today(), 'Test'); }
        catch (AuraHandledException ex) { thrown = true; }
        Test.stopTest();
        System.assert(thrown, 'Should throw for blank Egg Size');
    }

    @IsTest
    static void testCreateEggRecord_futureDate() {
        Boolean thrown = false;
        Test.startTest();
        try { eggController_copado.createEggRecord('Goose', 'Jumbo', Date.today().addDays(5), 'Future'); }
        catch (AuraHandledException ex) { thrown = true; }
        Test.stopTest();
        System.assert(thrown, 'Should throw for future date');
    }

    @IsTest
    static void testCreateEggRecord_bulk() {
        List<Egg__c> eggs = new List<Egg__c>();
        for (Integer i = 0; i < 200; i++) {
            eggs.add(new Egg__c(Egg_Type__c='Turkey', Egg_Size__c='Extra Large', Date_Collected__c=Date.today(), Active__c=true));
        }
        Test.startTest();
        insert eggs;
        Test.stopTest();
        System.assertEquals(200, [SELECT COUNT() FROM Egg__c WHERE Egg_Type__c = 'Turkey']);
    }
}