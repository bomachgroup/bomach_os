/// Curated country → state → city dataset used by [CountryStateCityPicker].
///
/// Coverage is pragmatic rather than exhaustive:
///   • Nigeria — all 36 states + FCT, with the most common cities each.
///   • United States / United Kingdom / Canada / Ghana / South Africa /
///     Kenya / United Arab Emirates — common administrative regions and
///     their primary cities.
///
/// Countries outside this dataset still appear in the country picker, but
/// state/city dropdowns gracefully fall back to a free-text entry.
library;

class CountryStateCity {
  CountryStateCity._();

  /// Country name → (State/Province/Region → list of cities).
  static const Map<String, Map<String, List<String>>> data = {
    // ───────────────────────── Nigeria ─────────────────────────
    'Nigeria': {
      'Abia': ['Umuahia', 'Aba', 'Arochukwu', 'Ohafia'],
      'Adamawa': ['Yola', 'Jimeta', 'Mubi', 'Numan', 'Ganye'],
      'Akwa Ibom': ['Uyo', 'Eket', 'Ikot Ekpene', 'Oron'],
      'Anambra': ['Awka', 'Onitsha', 'Nnewi', 'Ekwulobia'],
      'Bauchi': ['Bauchi', 'Azare', 'Misau', 'Jamaare'],
      'Bayelsa': ['Yenagoa', 'Brass', 'Sagbama', 'Nembe'],
      'Benue': ['Makurdi', 'Gboko', 'Otukpo', 'Katsina-Ala'],
      'Borno': ['Maiduguri', 'Biu', 'Bama', 'Dikwa'],
      'Cross River': ['Calabar', 'Ikom', 'Ogoja', 'Obudu'],
      'Delta': ['Asaba', 'Warri', 'Sapele', 'Ughelli', 'Agbor'],
      'Ebonyi': ['Abakaliki', 'Afikpo', 'Onueke', 'Ezza'],
      'Edo': ['Benin City', 'Auchi', 'Ekpoma', 'Uromi'],
      'Ekiti': ['Ado-Ekiti', 'Ikere', 'Ikole', 'Omuo-Ekiti'],
      'Enugu': ['Enugu', 'Nsukka', 'Agbani', 'Awgu'],
      'FCT - Abuja': ['Abuja', 'Gwagwalada', 'Kuje', 'Bwari', 'Kwali'],
      'Gombe': ['Gombe', 'Billiri', 'Kaltungo', 'Dukku'],
      'Imo': ['Owerri', 'Orlu', 'Okigwe', 'Mbaise'],
      'Jigawa': ['Dutse', 'Hadejia', 'Gumel', 'Kazaure'],
      'Kaduna': ['Kaduna', 'Zaria', 'Kafanchan', 'Sabon Gari'],
      'Kano': ['Kano', 'Wudil', 'Gwarzo', 'Rano'],
      'Katsina': ['Katsina', 'Daura', 'Funtua', 'Malumfashi'],
      'Kebbi': ['Birnin Kebbi', 'Argungu', 'Yauri', 'Zuru'],
      'Kogi': ['Lokoja', 'Okene', 'Idah', 'Kabba'],
      'Kwara': ['Ilorin', 'Offa', 'Jebba', 'Omu-Aran'],
      'Lagos': [
        'Ikeja',
        'Lagos Island',
        'Lekki',
        'Victoria Island',
        'Surulere',
        'Yaba',
        'Ikorodu',
        'Agege',
        'Ajah',
        'Apapa',
        'Badagry',
        'Epe',
        'Festac',
        'Gbagada',
        'Maryland',
        'Ojo',
        'Oshodi',
      ],
      'Nasarawa': ['Lafia', 'Keffi', 'Akwanga', 'Nasarawa'],
      'Niger': ['Minna', 'Bida', 'Suleja', 'Kontagora'],
      'Ogun': [
        'Abeokuta',
        'Ijebu-Ode',
        'Sagamu',
        'Ota',
        'Ifo',
        'Mowe',
      ],
      'Ondo': ['Akure', 'Ondo', 'Owo', 'Ikare-Akoko'],
      'Osun': ['Osogbo', 'Ile-Ife', 'Ilesa', 'Iwo'],
      'Oyo': ['Ibadan', 'Ogbomoso', 'Iseyin', 'Oyo', 'Saki'],
      'Plateau': ['Jos', 'Bukuru', 'Pankshin', 'Shendam'],
      'Rivers': ['Port Harcourt', 'Bonny', 'Omoku', 'Bori'],
      'Sokoto': ['Sokoto', 'Wurno', 'Tambuwal', 'Illela'],
      'Taraba': ['Jalingo', 'Wukari', 'Bali', 'Takum'],
      'Yobe': ['Damaturu', 'Potiskum', 'Gashua', 'Nguru'],
      'Zamfara': ['Gusau', 'Kaura Namoda', 'Tsafe', 'Anka'],
    },

    // ───────────────────────── United States ─────────────────────────
    'United States': {
      'Alabama': ['Birmingham', 'Montgomery', 'Mobile', 'Huntsville'],
      'Alaska': ['Anchorage', 'Fairbanks', 'Juneau'],
      'Arizona': ['Phoenix', 'Tucson', 'Mesa', 'Scottsdale'],
      'Arkansas': ['Little Rock', 'Fayetteville', 'Fort Smith'],
      'California': [
        'Los Angeles',
        'San Francisco',
        'San Diego',
        'Sacramento',
        'San Jose',
        'Oakland',
      ],
      'Colorado': ['Denver', 'Colorado Springs', 'Aurora', 'Boulder'],
      'Connecticut': ['Hartford', 'Bridgeport', 'New Haven', 'Stamford'],
      'Delaware': ['Wilmington', 'Dover', 'Newark'],
      'Florida': ['Miami', 'Orlando', 'Tampa', 'Jacksonville', 'Tallahassee'],
      'Georgia': ['Atlanta', 'Savannah', 'Augusta', 'Athens'],
      'Hawaii': ['Honolulu', 'Hilo', 'Kailua'],
      'Idaho': ['Boise', 'Meridian', 'Nampa'],
      'Illinois': ['Chicago', 'Springfield', 'Aurora', 'Naperville'],
      'Indiana': ['Indianapolis', 'Fort Wayne', 'Evansville'],
      'Iowa': ['Des Moines', 'Cedar Rapids', 'Davenport'],
      'Kansas': ['Wichita', 'Kansas City', 'Topeka'],
      'Kentucky': ['Louisville', 'Lexington', 'Frankfort'],
      'Louisiana': ['New Orleans', 'Baton Rouge', 'Shreveport'],
      'Maine': ['Portland', 'Augusta', 'Bangor'],
      'Maryland': ['Baltimore', 'Annapolis', 'Frederick'],
      'Massachusetts': ['Boston', 'Worcester', 'Cambridge', 'Springfield'],
      'Michigan': ['Detroit', 'Grand Rapids', 'Ann Arbor', 'Lansing'],
      'Minnesota': ['Minneapolis', 'Saint Paul', 'Rochester'],
      'Mississippi': ['Jackson', 'Gulfport', 'Biloxi'],
      'Missouri': ['Kansas City', 'Saint Louis', 'Jefferson City'],
      'Montana': ['Billings', 'Missoula', 'Helena'],
      'Nebraska': ['Omaha', 'Lincoln', 'Bellevue'],
      'Nevada': ['Las Vegas', 'Reno', 'Carson City'],
      'New Hampshire': ['Manchester', 'Concord', 'Nashua'],
      'New Jersey': ['Newark', 'Jersey City', 'Trenton', 'Atlantic City'],
      'New Mexico': ['Albuquerque', 'Santa Fe', 'Las Cruces'],
      'New York': ['New York City', 'Buffalo', 'Albany', 'Rochester'],
      'North Carolina': ['Charlotte', 'Raleigh', 'Greensboro', 'Durham'],
      'North Dakota': ['Fargo', 'Bismarck', 'Grand Forks'],
      'Ohio': ['Columbus', 'Cleveland', 'Cincinnati', 'Toledo'],
      'Oklahoma': ['Oklahoma City', 'Tulsa', 'Norman'],
      'Oregon': ['Portland', 'Salem', 'Eugene'],
      'Pennsylvania': ['Philadelphia', 'Pittsburgh', 'Harrisburg'],
      'Rhode Island': ['Providence', 'Warwick', 'Newport'],
      'South Carolina': ['Charleston', 'Columbia', 'Greenville'],
      'South Dakota': ['Sioux Falls', 'Pierre', 'Rapid City'],
      'Tennessee': ['Nashville', 'Memphis', 'Knoxville', 'Chattanooga'],
      'Texas': ['Houston', 'Dallas', 'Austin', 'San Antonio', 'Fort Worth'],
      'Utah': ['Salt Lake City', 'Provo', 'West Valley City'],
      'Vermont': ['Burlington', 'Montpelier', 'Rutland'],
      'Virginia': ['Virginia Beach', 'Richmond', 'Norfolk', 'Arlington'],
      'Washington': ['Seattle', 'Olympia', 'Tacoma', 'Spokane'],
      'West Virginia': ['Charleston', 'Huntington', 'Morgantown'],
      'Wisconsin': ['Milwaukee', 'Madison', 'Green Bay'],
      'Wyoming': ['Cheyenne', 'Casper', 'Laramie'],
    },

    // ───────────────────────── United Kingdom ─────────────────────────
    'United Kingdom': {
      'England': [
        'London',
        'Manchester',
        'Birmingham',
        'Liverpool',
        'Leeds',
        'Bristol',
        'Newcastle',
        'Sheffield',
      ],
      'Scotland': ['Edinburgh', 'Glasgow', 'Aberdeen', 'Dundee', 'Inverness'],
      'Wales': ['Cardiff', 'Swansea', 'Newport', 'Wrexham'],
      'Northern Ireland': ['Belfast', 'Derry', 'Lisburn', 'Newry'],
    },

    // ───────────────────────── Canada ─────────────────────────
    'Canada': {
      'Alberta': ['Calgary', 'Edmonton', 'Red Deer'],
      'British Columbia': ['Vancouver', 'Victoria', 'Kelowna'],
      'Manitoba': ['Winnipeg', 'Brandon'],
      'New Brunswick': ['Fredericton', 'Saint John', 'Moncton'],
      'Newfoundland and Labrador': ['St. John\'s', 'Corner Brook'],
      'Nova Scotia': ['Halifax', 'Sydney', 'Dartmouth'],
      'Ontario': ['Toronto', 'Ottawa', 'Hamilton', 'Mississauga', 'London'],
      'Prince Edward Island': ['Charlottetown', 'Summerside'],
      'Quebec': ['Montreal', 'Quebec City', 'Laval', 'Gatineau'],
      'Saskatchewan': ['Saskatoon', 'Regina'],
    },

    // ───────────────────────── Ghana ─────────────────────────
    'Ghana': {
      'Greater Accra': ['Accra', 'Tema', 'Madina'],
      'Ashanti': ['Kumasi', 'Obuasi', 'Ejisu'],
      'Western': ['Sekondi-Takoradi', 'Tarkwa', 'Axim'],
      'Central': ['Cape Coast', 'Winneba', 'Kasoa'],
      'Eastern': ['Koforidua', 'Akosombo', 'Nkawkaw'],
      'Volta': ['Ho', 'Keta', 'Hohoe'],
      'Northern': ['Tamale', 'Yendi', 'Savelugu'],
      'Upper East': ['Bolgatanga', 'Bawku', 'Navrongo'],
      'Upper West': ['Wa', 'Lawra', 'Tumu'],
      'Bono': ['Sunyani', 'Berekum', 'Dormaa Ahenkro'],
    },

    // ───────────────────────── South Africa ─────────────────────────
    'South Africa': {
      'Eastern Cape': ['Port Elizabeth', 'East London', 'Mthatha'],
      'Free State': ['Bloemfontein', 'Welkom', 'Bethlehem'],
      'Gauteng': ['Johannesburg', 'Pretoria', 'Soweto', 'Sandton'],
      'KwaZulu-Natal': ['Durban', 'Pietermaritzburg', 'Richards Bay'],
      'Limpopo': ['Polokwane', 'Thohoyandou', 'Tzaneen'],
      'Mpumalanga': ['Nelspruit', 'Witbank', 'Secunda'],
      'Northern Cape': ['Kimberley', 'Upington', 'Springbok'],
      'North West': ['Mahikeng', 'Rustenburg', 'Klerksdorp'],
      'Western Cape': ['Cape Town', 'Stellenbosch', 'George', 'Paarl'],
    },

    // ───────────────────────── Kenya ─────────────────────────
    'Kenya': {
      'Nairobi': ['Nairobi', 'Westlands', 'Karen', 'Kasarani'],
      'Mombasa': ['Mombasa', 'Nyali', 'Kisauni'],
      'Kisumu': ['Kisumu', 'Ahero'],
      'Nakuru': ['Nakuru', 'Naivasha', 'Gilgil'],
      'Uasin Gishu': ['Eldoret', 'Burnt Forest'],
      'Kiambu': ['Thika', 'Ruiru', 'Kikuyu'],
      'Machakos': ['Machakos', 'Athi River'],
      'Kajiado': ['Kajiado', 'Ngong', 'Ongata Rongai'],
    },

    // ───────────────────────── United Arab Emirates ─────────────────────────
    'United Arab Emirates': {
      'Abu Dhabi': ['Abu Dhabi', 'Al Ain', 'Madinat Zayed'],
      'Dubai': ['Dubai', 'Jebel Ali', 'Hatta'],
      'Sharjah': ['Sharjah', 'Khor Fakkan', 'Kalba'],
      'Ajman': ['Ajman', 'Masfout'],
      'Umm Al Quwain': ['Umm Al Quwain'],
      'Ras Al Khaimah': ['Ras Al Khaimah'],
      'Fujairah': ['Fujairah', 'Dibba'],
    },
  };

  /// All supported country names (those with curated state lists).
  static List<String> get supportedCountries =>
      data.keys.toList()..sort();

  /// States for a given country, or null if the country isn't in the dataset.
  static List<String>? statesFor(String? country) {
    if (country == null) return null;
    final entry = data[country];
    return entry == null ? null : (entry.keys.toList()..sort());
  }

  /// Cities for a given country + state, or null if either isn't in the dataset.
  static List<String>? citiesFor(String? country, String? state) {
    if (country == null || state == null) return null;
    return data[country]?[state];
  }
}
