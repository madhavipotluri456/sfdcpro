public inherited sharing class RemotingDashboardController {
    
    public RemotingDashboardController() {}

    @RemoteAction
    public static List<Map<String, Object>> getIndustryAggregationMetrics() {
        List<Map<String, Object>> dataPayload = new List<Map<String, Object>>();
        for (AggregateResult result : [SELECT Industry, COUNT(Id) recordCount, SUM(AnnualRevenue) totalRevenue FROM Account WHERE Industry != null GROUP BY Industry LIMIT 10]) {
            Map<String, Object> node = new Map<String, Object>();
            node.put('industry', result.get('Industry'));
            node.put('count', result.get('recordCount'));
            node.put('revenue', result.get('totalRevenue'));
            dataPayload.add(node);
        }
        return dataPayload;
    }
}
