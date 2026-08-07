package helpers;

import org.testng.Assert;
import org.testng.annotations.Test;
import utils.JsonUtils;

public class ValueExpressionHelperTest {

    @Test
    public void concatLiteralsAndPlaceholder() {
        String resolved = ValueExpressionHelper.resolve(
                "\"abdc\"+{RANDOM_STRING:6}+\"yopmail.com\"",
                s -> s.replace("{RANDOM_STRING:6}", "ABCDEF")
        );
        Assert.assertEquals(resolved, "abdcABCDEFyopmail.com");
    }

    @Test
    public void concatPreservesQuotedSpaces() {
        String resolved = ValueExpressionHelper.resolve(
                "\" \"+{RANDOM_STRING:4}",
                s -> s.replace("{RANDOM_STRING:4}", "WXYZ")
        );
        Assert.assertEquals(resolved, " WXYZ");
    }

    @Test
    public void bracedExpressionWithBareRandomToken() {
        String resolved = ValueExpressionHelper.resolve(
                "{\"abdc\"+RANDOM_STRING:5+\"yopmail.com\"}",
                s -> s.replace("{RANDOM_STRING:5}", "HELLO")
        );
        Assert.assertEquals(resolved, "abdcHELLOyopmail.com");
    }

    @Test
    public void embeddedPlaceholderWithoutConcatStillWorks() {
        String resolved = ValueExpressionHelper.resolve(
                "abdc{RANDOM_STRING:3}yopmail.com",
                s -> s.replace("{RANDOM_STRING:3}", "ZZZ")
        );
        Assert.assertEquals(resolved, "abdcZZZyopmail.com");
    }

    @Test
    public void leadingSpacesArePreservedForAutoType() {
        Object value = JsonUtils.parseTypedValue("auto", "  keep-spaces  ");
        Assert.assertEquals(value, "  keep-spaces  ");
    }

    @Test
    public void stripSurroundingQuotesDoesNotTrimInnerSpaces() {
        Assert.assertEquals(PayloadHelper.stripSurroundingQuotes("  hello  "), "  hello  ");
        Assert.assertEquals(PayloadHelper.stripSurroundingQuotes("\"  hello  \""), "  hello  ");
    }
}
