import requests
from bs4 import BeautifulSoup
from icalendar import Calendar, Event
from datetime import datetime, timedelta
import pytz
import re
import uuid

BALFOLK_URL = "https://www.balfolk.nl/agenda/"

def dutch_to_english_date(dutch_date_str):
    months = {
        "jan": "Jan",
        "feb": "Feb",
        "mrt": "Mar",
        "apr": "Apr",
        "mei": "May",
        "jun": "Jun",
        "jul": "Jul",
        "aug": "Aug",
        "sep": "Sep",
        "okt": "Oct",
        "nov": "Nov",
        "dec": "Dec"
    }
    for nl, en in months.items():
        dutch_date_str = re.sub(r'\b' + nl + r'\b', en, dutch_date_str, flags=re.IGNORECASE)
    return dutch_date_str

def fetch_balfolk_events():
    response = requests.get(BALFOLK_URL)
    response.raise_for_status()

    soup = BeautifulSoup(response.text, "html.parser")
    events = []

    for li in soup.select("ul#response li.flex-container"):
        date_location = li.select_one(".date")
        title_link = li.select_one(".title a")
        plug_link = li.select_one("a[href^='https://www.plug.events/event/']")

        if not date_location or not title_link:
            continue

        date_loc_text = date_location.text.strip()
        title_text = title_link.text.strip()
        plug_url = plug_link["href"] if plug_link else None

        try:
            date_part, location = map(str.strip, date_loc_text.split("|"))
            date_clean = " ".join(date_part.split(" ")[1:])  # skip weekday (e.g. "zo 12 okt 2025" → "12 okt 2025")
            date_clean = dutch_to_english_date(date_clean)
            event_date = datetime.strptime(date_clean, "%d %b %Y")
        except Exception as e:
            print(f"Skipping event due to date parse error: {e} → {date_loc_text}")
            continue

        events.append({
            "date": event_date,
            "name": title_text,
            "location": location,
            "plug_url": plug_url,
        })

    return events


def replace_year(dt, new_year):
    return dt.replace(year=new_year)

def fix_years(start_dt, end_dt):
    current_year = datetime.now().year

    start_year = start_dt.year
    end_year = end_dt.year

    if start_year == 1900 and end_year != 1900:
        start_dt = replace_year(start_dt, end_year)
    elif end_year == 1900 and start_year != 1900:
        end_dt = replace_year(end_dt, start_year)
    elif start_year == 1900 and end_year == 1900:
        start_dt = replace_year(start_dt, current_year)
        end_dt = replace_year(end_dt, current_year)

    return start_dt, end_dt

def parse_event_datetime(datetime_str):
    tz = pytz.timezone("Europe/Amsterdam")
    datetime_str = datetime_str.strip()
    datetime_str = datetime_str.replace(';', '')  # remove semicolon if present

    try:
        # Case 1: "January 9 4:00 PM - January 12, 2026 (Fri-Mon)"
        m = re.match(r'^([A-Za-z]+ \d{1,2} \d{1,2}:\d{2} [AP]M) - ([A-Za-z]+ \d{1,2}, \d{4})(?: \(.+\))?$', datetime_str)
        if m:
            start_str, end_str = m.groups()
            start_naive = datetime.strptime(start_str, "%B %d %I:%M %p")
            end_naive = datetime.strptime(end_str, "%B %d, %Y")
            end_naive += timedelta(days=1)
            start_naive, end_naive = fix_years(start_naive, end_naive)
            return tz.localize(start_naive), tz.localize(end_naive)

        # Case 2: "November 14 - 17, 2025 (Fri-Mon)"
        m_partial_same_month = re.match(r'^([A-Za-z]+) (\d{1,2}) - (\d{1,2}), (\d{4})(?: \(.+\))?$', datetime_str)
        if m_partial_same_month:
            month, start_day, end_day, year = m_partial_same_month.groups()
            start_str = f"{month} {start_day}, {year}"
            end_str = f"{month} {end_day}, {year}"
            start_naive = datetime.strptime(start_str, "%B %d, %Y")
            end_naive = datetime.strptime(end_str, "%B %d, %Y") + timedelta(days=1)
            start_naive, end_naive = fix_years(start_naive, end_naive)
            return tz.localize(start_naive), tz.localize(end_naive)

        # Case 3: Full range with repeated months: "September 10 - November 19, 2025"
        m_partial_range = re.match(r'^([A-Za-z]+ \d{1,2}) - ([A-Za-z]+ \d{1,2}, \d{4})(?: \(.+\))?$', datetime_str)
        if m_partial_range:
            start_date_part, end_date_part = m_partial_range.groups()
            end_date_obj = datetime.strptime(end_date_part, "%B %d, %Y")
            start_date_str = f"{start_date_part}, {end_date_obj.year}"
            start_naive = datetime.strptime(start_date_str, "%B %d, %Y")
            end_naive = end_date_obj + timedelta(days=1)
            start_naive, end_naive = fix_years(start_naive, end_naive)
            return tz.localize(start_naive), tz.localize(end_naive)

        # Case 4: Full date ranges: "September 8, 2025 - January 12, 2026"
        m_full_range = re.match(r'^([A-Za-z]+ \d{1,2}, \d{4}) - ([A-Za-z]+ \d{1,2}, \d{4})(?: \(.+\))?$', datetime_str)
        if m_full_range:
            start_str, end_str = m_full_range.groups()
            start_naive = datetime.strptime(start_str, "%B %d, %Y")
            end_naive = datetime.strptime(end_str, "%B %d, %Y") + timedelta(days=1)
            start_naive, end_naive = fix_years(start_naive, end_naive)
            return tz.localize(start_naive), tz.localize(end_naive)

        # Case 5: Original format with parentheses and time range (AM/PM support)
        date_part = datetime_str.split('(')[0].strip()
        time_part = datetime_str.split(')')[1].strip()

        time_range = [t.strip() for t in time_part.split('-')]
        if len(time_range) != 2:
            raise ValueError("Invalid time range")

        start_time, end_time = time_range
        is_am_pm = bool(re.search(r'\bAM\b|\bPM\b', start_time, re.IGNORECASE))

        if is_am_pm:
            dt_format = "%B %d, %Y %I:%M %p"
        else:
            dt_format = "%B %d, %Y %H:%M"

        start_str = f"{date_part} {start_time}"
        end_str = f"{date_part} {end_time}"

        start_naive = datetime.strptime(start_str, dt_format)
        end_naive = datetime.strptime(end_str, dt_format)

        start_naive, end_naive = fix_years(start_naive, end_naive)
        return tz.localize(start_naive), tz.localize(end_naive)

    except Exception as e:
        print(f"Error parsing datetime '{datetime_str}': {e}")
        return None, None


def fetch_event_detail(plug_url):
    try:
        r = requests.get(plug_url)
        r.raise_for_status()
        soup = BeautifulSoup(r.text, "html.parser")

        description_div = soup.find("div", class_="description")
        summary_text = ""
        if description_div:
            p = description_div.find("p")
            if p:
                for br in p.find_all("br"):
                    br.replace_with("\n")
                summary_text = p.get_text(strip=True, separator="\n")

        # Look for detailed schedule
        schedule_div = soup.select_one("div.event-schedule")
        if schedule_div:
            datetimes = []
            for h3 in schedule_div.find_all("h3"):
                text = h3.get_text(strip=True)  # ✅ grabs text from all nested spans
                if not text:
                    continue
                start_dt, end_dt = parse_event_datetime(text)
                if start_dt and end_dt:
                    datetimes.append((start_dt, end_dt))
        
            if not datetimes:
                print(f"⚠️ Schedule found but no valid date-times parsed for {plug_url}")
        
            return summary_text.strip(), datetimes


        # If no schedule was found, fallback to top-level <li> datetime
        for li in soup.find_all("li"):
            if li.find("i", class_="pi pi-calendar"):
                span = li.find("span")
                if span:
                    datetime_str = span.get_text(strip=True)
                    start_dt, end_dt = parse_event_datetime(datetime_str)
                    if start_dt and end_dt:
                        return summary_text.strip(), [(start_dt, end_dt)]
                break

        return summary_text.strip(), []

    except Exception as e:
        print(f"❌ Error fetching plug.events details from {plug_url}: {e}")
        return None, []

def main():
    events = fetch_balfolk_events()

    cal = Calendar()
    cal.add("prodid", "-//Balfolk Calendar//balfolk.nl//")
    cal.add("version", "2.0")

    tz = pytz.timezone("Europe/Amsterdam")

    for ev in events:
        print(f"Processing event: {ev['name']}")

        summary = None
        dtstart = None
        dtend = None

        if ev["plug_url"]:
            plug_summary, ranges = fetch_event_detail(ev["plug_url"])
            summaries = [plug_summary or f"Details not available for {ev['name']}"] * len(ranges)
            datetimes = ranges

        if not datetimes:
            # Fallback: full day event using balfolk.nl date
            tz = pytz.timezone("Europe/Amsterdam")
            dtstart = tz.localize(datetime(ev["date"].year, ev["date"].month, ev["date"].day))
            dtend = dtstart + timedelta(days=1)
            datetimes = [(dtstart, dtend)]
            summaries = [f"{ev['name']} (details unavailable)"]

        for (dtstart, dtend), summary in zip(datetimes, summaries):
            event = Event()
            event.add("uid", str(uuid.uuid4()))
            event.add("summary", ev["name"])
            event.add("description", summary)
            event.add("dtstart", dtstart)
            event.add("dtend", dtend)
            event.add("location", ev["location"])
            if ev["plug_url"]:
                event.add("url", ev["plug_url"])
            cal.add_component(event)

    with open("balfolk.ics", "wb") as f:
        f.write(cal.to_ical())
    print("ICS file generated as balfolk.ics")

def validate_ics_file(filename="balfolk.ics"):
    print("\nValidating ICS file...\n")
    try:
        with open(filename, "rb") as f:
            cal = Calendar.from_ical(f.read())

        errors = 0
        for component in cal.walk():
            if component.name == "VEVENT":
                summary = component.get("summary")
                dtstart = component.get("dtstart")
                dtend = component.get("dtend")
                description = component.get("description")

                if not summary:
                    print("❌ Missing SUMMARY (required)")
                    errors += 1
                if not dtstart:
                    print(f"❌ Event '{summary}' is missing DTSTART (required)")
                    errors += 1
                if not dtend:
                    print(f"❌ Event '{summary}' is missing DTEND (required)")
                    errors += 1

                # Optional: warn if description is missing but don't count as error
                if not description:
                    print(f"⚠️ Event '{summary}' is missing DESCRIPTION (optional)")

                # Check timezone info on dtstart if present
                if dtstart:
                    if hasattr(dtstart.dt, 'tzinfo'):
                        if dtstart.dt.tzinfo is None:
                            print(f"⚠️  Event '{summary}' has naive datetime (no tzinfo)")
                        elif "Amsterdam" not in str(dtstart.dt.tzinfo):
                            print(f"⚠️  Event '{summary}' tzinfo is {dtstart.dt.tzinfo}, expected Europe/Amsterdam")
                    else:
                        print(f"⚠️  Event '{summary}' DTSTART is not a datetime object")

        if errors == 0:
            print("✅ ICS validation passed: All required fields present.")
        else:
            print(f"❌ Validation found {errors} error(s) with required fields.")

    except Exception as e:
        print(f"❌ Failed to read or parse ICS file: {e}")

if __name__ == "__main__":
    main()
    validate_ics_file("balfolk.ics")
