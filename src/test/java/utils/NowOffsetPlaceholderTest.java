package utils;

import context.TestContext;
import org.testng.Assert;
import org.testng.annotations.Test;

import java.time.ZoneId;
import java.time.ZonedDateTime;
import java.time.format.DateTimeFormatter;

public class NowOffsetPlaceholderTest {

    @Test
    public void nowOffsetDaysPastProducesIsoDate() {
        TestDataHelper helper = new TestDataHelper(new TestContext());
        String resolved = helper.replacePlaceholders("{NOW_OFFSET:-7:days:iso_date}");
        String expected = ZonedDateTime.now(ZoneId.systemDefault())
                .minusDays(7)
                .format(DateTimeFormatter.ofPattern("yyyy-MM-dd"));
        Assert.assertEquals(resolved, expected);
    }

    @Test
    public void nowOffsetDoesNotGetEatenByNowPlaceholder() {
        TestDataHelper helper = new TestDataHelper(new TestContext());
        String resolved = helper.replacePlaceholders("{NOW_OFFSET:0:days:iso_date}");
        String today = ZonedDateTime.now(ZoneId.systemDefault())
                .format(DateTimeFormatter.ofPattern("yyyy-MM-dd"));
        Assert.assertEquals(resolved, today);
    }
}
