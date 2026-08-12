package context;

import org.testng.Assert;
import org.testng.annotations.Test;

import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

public class CapturedPathTest {

    @Test
    public void resolvesMapFieldAndListIndex() {
        TestContext ctx = new TestContext();

        Map<String, Object> meta = new LinkedHashMap<>();
        meta.put("source", "crm");
        meta.put("batch", 12);
        ctx.captureObject("meta", meta);

        ctx.captureObject("tags", List.of("alpha", "beta", "gamma"));

        Assert.assertEquals(ctx.getCapturedValue("meta.source"), "crm");
        Assert.assertEquals(ctx.getCapturedValue("meta.batch"), "12");
        Assert.assertEquals(ctx.getCapturedValue("tags[0]"), "alpha");
        Assert.assertEquals(ctx.getCapturedValue("tags[2]"), "gamma");
        Assert.assertTrue(ctx.hasCapturedPath("meta.source"));
        Assert.assertTrue(ctx.hasCapturedPath("tags[1]"));
    }

    @Test
    public void resolvesNestedListOfMaps() {
        TestContext ctx = new TestContext();
        Map<String, Object> first = new LinkedHashMap<>();
        first.put("id", "L-100");
        ctx.captureObject("items", List.of(first));

        Assert.assertEquals(ctx.getCapturedValue("items[0].id"), "L-100");
    }
}
