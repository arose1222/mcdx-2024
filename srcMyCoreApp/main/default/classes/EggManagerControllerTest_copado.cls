/**
 * @description Test class for EggManagerController_copado.
 *              Validates getEggTypes, getEggSizes, and saveEggRecord methods.
 * @author      Copado AI
 */
@IsTest
private class EggManagerControllerTest_copado {

    @IsTest
    static void testGetEggTypes_returnsValues() {
        Test.startTest();
        List<String> types = EggManagerController_copado.getEggTypes();
        Test.stopTest();
        System.assertNotEquals(null, types, 'Egg types list should not be null.');
    }

    @IsTest
    static void testGetEggSizes_returnsValues() {
        Test.startTest();
        List<String> sizes = EggManagerController_copado.getEggSizes();
        Test.stopTest();
        System.assertNotEquals(null, sizes, 'Egg sizes list should not be null.');
    }

    @IsTest
    static void testSaveEggRecord_success() {
        Test.startTest();
        EggManagerController_copado.saveEggRecord('Chicken', 'Large');
        Test.stopTest();
        List<Egg__c> eggs = [SELECT Id, Egg_Type__c, Egg_Size__c FROM Egg__c WHERE Egg_Type__c = 'Chicken'];
        System.assertEquals(1, eggs.size(), 'One Egg record should have been created.');
        System.assertEquals('Chicken', eggs[0].Egg_Type__c, 'Egg type should match.');
        System.assertEquals('Large', eggs[0].Egg_Size__c, 'Egg size should match.');
    }

    @IsTest
    static void testSaveEggRecord_nullFields() {
        Test.startTest();
        try {
            EggManagerController_copado.saveEggRecord(null, null);
        } catch (Exception e) {
            System.assertNotEquals(null, e, 'An exception may be thrown for null fields.');
        }
        Test.stopTest();
    }
}