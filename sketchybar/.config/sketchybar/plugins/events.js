// Calendar events for today and the following days, read through EventKit.
// Usage: osascript -l JavaScript events.js <days>
// Prints one line per event and day it touches, sorted, all-day first:
//   YYYY-MM-DD <TAB> time, padded to 11 chars <TAB> 0xffRRGGBB <TAB> title
// The colour is the event's calendar colour.
ObjC.import("EventKit");
ObjC.import("AppKit");

function run(argv) {
  const days = parseInt(argv[0], 10) || 4;
  const pad = (n) => String(n).padStart(2, "0");
  const hm = (d) => pad(d.getHours()) + ":" + pad(d.getMinutes());
  const ymd = (d) => d.getFullYear() + "-" + pad(d.getMonth() + 1) + "-" + pad(d.getDate());
  const js = (d) => new Date(d.timeIntervalSince1970 * 1000);
  const ns = (d) => $.NSDate.dateWithTimeIntervalSince1970(d.getTime() / 1000);
  const now = new Date();
  const day = (i) => new Date(now.getFullYear(), now.getMonth(), now.getDate() + i);

  // 3 = full access to events.
  if (Number($.EKEventStore.authorizationStatusForEntityType(0)) !== 3) {
    throw new Error("no calendar access");
  }

  const store = $.EKEventStore.alloc.init;
  const events = store.eventsMatchingPredicate(
    store.predicateForEventsWithStartDateEndDateCalendars(ns(day(0)), ns(day(days)), $()));
  const count = events.isNil() ? 0 : events.count;

  const rows = [];
  for (let n = 0; n < count; n++) {
    const ev = events.objectAtIndex(n);
    const start = js(ev.startDate), end = js(ev.endDate);
    const rgb = ev.calendar.color.colorUsingColorSpace($.NSColorSpace.sRGBColorSpace);
    const color = "0xff" + [rgb.redComponent, rgb.greenComponent, rgb.blueComponent]
      .map((c) => Math.round(c * 255).toString(16).padStart(2, "0")).join("");
    const title = (ObjC.unwrap(ev.title) || "").replace(/\s+/g, " ").trim() || "(no title)";

    for (let i = 0; i < days; i++) {
      const from = day(i), to = day(i + 1);
      if (start >= to || end < from || (end <= from && start < from)) continue;
      const whole = ev.allDay || (start <= from && end >= to);
      let time;
      if (whole)              time = "all day";
      else if (start < from)  time = "–" + hm(end);          // ends today
      else if (end > to)      time = hm(start);              // ends another day
      else                    time = hm(start) + "–" + hm(end);
      rows.push({
        key: ymd(from) + (whole ? "0" : "1") + hm(start < from ? from : start),
        line: [ymd(from), time.padEnd(11), color, title].join("\t"),
      });
    }
  }
  rows.sort((a, b) => (a.key < b.key ? -1 : a.key > b.key ? 1 : 0));
  return rows.map((r) => r.line).join("\n");
}
