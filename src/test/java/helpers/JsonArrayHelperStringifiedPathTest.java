package helpers;

import org.testng.Assert;
import org.testng.annotations.Test;

import java.util.List;
import java.util.Map;

public class JsonArrayHelperStringifiedPathTest {

    private static final String BODY = """
            {
              "success": true,
              "output": "{\\"variable_filter_value\\": [{\\"label\\": \\"Partially Recovered\\", \\"value\\": 215313}, {\\"label\\": \\"Fully Recovered\\", \\"value\\": 215318}, {\\"label\\": \\"Not Recovered\\", \\"value\\": 215334}, {\\"label\\": \\"Not Available\\", \\"value\\": 215376}], \\"variable_type\\": \\"list\\"}",
              "message": "success"
            }
            """;

    @Test
    public void resolvesArrayInsideStringifiedOutput() {
        Object raw = JsonArrayHelper.resolveThroughStringifiedJson(BODY, "output.variable_filter_value");
        Assert.assertTrue(raw instanceof List<?>);
        @SuppressWarnings("unchecked")
        List<Map<String, Object>> list = (List<Map<String, Object>>) raw;
        Assert.assertEquals(list.size(), 4);
        Assert.assertEquals(String.valueOf(list.get(2).get("label")), "Not Recovered");
        Assert.assertEquals(((Number) list.get(2).get("value")).intValue(), 215334);
    }

    @Test
    public void returnsNullForMissingNestedPath() {
        Assert.assertNull(JsonArrayHelper.resolveThroughStringifiedJson(BODY, "output.missing"));
    }

    @Test
    public void findsLabelInsideHeaderListOptions() {
        String headerListBody = """
                {
                  "output": "{\\"variable_filter_value\\": [{\\"header\\": \\"High\\", \\"options\\": [{\\"label\\": \\"Initiated\\", \\"value\\": 53482}, {\\"label\\": \\"AutoQA\\", \\"value\\": 53864}]}, {\\"header\\": \\"Others\\", \\"options\\": [{\\"label\\": \\"Closed\\", \\"value\\": 53490}]}], \\"variable_type\\": \\"header-list\\"}"
                }
                """;
        Object raw = JsonArrayHelper.resolveThroughStringifiedJson(
                headerListBody, "output.variable_filter_value");
        @SuppressWarnings("unchecked")
        List<Map<String, Object>> list = (List<Map<String, Object>>) raw;
        Map<String, Object> match =
                JsonArrayHelper.findObjectByReference(list, "label", "Initiated");
        Assert.assertEquals(((Number) match.get("value")).intValue(), 53482);
    }
}
