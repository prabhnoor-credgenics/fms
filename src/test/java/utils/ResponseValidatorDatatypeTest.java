package utils;

import org.testng.Assert;
import org.testng.annotations.Test;

import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

public class ResponseValidatorDatatypeTest {

    @Test
    public void autoCoerceBooleanNumberStringNull() {
        Assert.assertEquals(ResponseValidator.coerceExpected(Boolean.TRUE, "true"), Boolean.TRUE);
        Assert.assertEquals(ResponseValidator.coerceExpected(Boolean.FALSE, "false"), Boolean.FALSE);
        ResponseValidator.assertValuesEqual("n", 401, ResponseValidator.coerceExpected(401, "401"));
        ResponseValidator.assertValuesEqual("d", 12.5, ResponseValidator.coerceExpected(12.5d, "12.5"));
        Assert.assertEquals(ResponseValidator.coerceExpected("hello", "hello"), "hello");
        Assert.assertNull(ResponseValidator.coerceExpected(null, "null"));
    }

    @Test
    public void autoCoerceMapAndList() {
        Map<String, Object> actualMap = new LinkedHashMap<>();
        actualMap.put("a", 1);
        actualMap.put("b", true);
        Object expectedMap = ResponseValidator.coerceExpected(actualMap, "{\"a\":1,\"b\":true}");
        ResponseValidator.assertValuesEqual("meta", actualMap, expectedMap);

        List<Object> actualList = List.of("a", "b");
        Object expectedList = ResponseValidator.coerceExpected(actualList, "[\"a\",\"b\"]");
        ResponseValidator.assertValuesEqual("tags", actualList, expectedList);
    }

    @Test
    public void typedParseJavaValues() {
        Assert.assertEquals(JsonUtils.parseTypedValueAsJava("boolean", "true"), Boolean.TRUE);
        Assert.assertEquals(JsonUtils.parseTypedValueAsJava("int", "10"), 10);
        Assert.assertEquals(JsonUtils.parseTypedValueAsJava("string", "401"), "401");
        Assert.assertTrue(JsonUtils.parseTypedValueAsJava("list", "[1,2]") instanceof List);
        Assert.assertTrue(JsonUtils.parseTypedValueAsJava("map", "{\"k\":true}") instanceof Map);
    }

    @Test
    public void typedJsonUpdateSupportsAllTypesAndDeepPaths() {
        String json = "{}";
        json = JsonUtils.updateJsonFieldTyped(json, "message", "string", "invalid authentication token");
        json = JsonUtils.updateJsonFieldTyped(json, "success", "boolean", "true");
        json = JsonUtils.updateJsonFieldTyped(json, "count", "int", "10");
        json = JsonUtils.updateJsonFieldTyped(json, "data.meta", "map", "{\"source\":\"api\"}");
        json = JsonUtils.updateJsonFieldTyped(json, "data.tags", "list", "[\"a\",\"b\"]");
        json = JsonUtils.updateJsonFieldTyped(json, "data.items[0].id", "string", "x1");
        json = JsonUtils.updateJsonFieldTyped(json, "nullable", "null", "null");

        Assert.assertTrue(json.contains("\"message\":\"invalid authentication token\""));
        Assert.assertTrue(json.contains("\"success\":true"));
        Assert.assertTrue(json.contains("\"count\":10"));
        Assert.assertTrue(json.contains("\"source\":\"api\""));
        Assert.assertTrue(json.contains("\"tags\":[\"a\",\"b\"]"));
        Assert.assertTrue(json.contains("\"id\":\"x1\""));
        Assert.assertTrue(json.contains("\"nullable\":null"));
    }
}
