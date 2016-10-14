// Copyright (c) 2014, the timezone project authors. Please see the AUTHORS
// file for details. All rights reserved. Use of this source code is governed
// by a BSD-style license that can be found in the LICENSE file.

library timezone.src.date_time;

import 'location.dart';
import 'env.dart';

/// TimeZone aware DateTime
class TZDateTime implements DateTime {
  /// Maximum value for time instants.
  static const int maxMillisecondsSinceEpoch = 8640000000000000;

  /// Minimum value for time instants.
  static const int minMillisecondsSinceEpoch = -maxMillisecondsSinceEpoch;

  /// Returns the native [DateTime] object.
  static DateTime _toNative(DateTime t) => t is TZDateTime ? t._native : t;

  /// Converts a [_localDateTime] into a correct [DateTime].
  static DateTime _utcFromLocalDateTime(DateTime local, Location location) {
    var unix = local.millisecondsSinceEpoch;
    var tzData = location.lookupTimeZone(unix);
    if (tzData.timeZone.offset != 0) {
      final utc = unix - tzData.timeZone.offset;
      if (utc < tzData.start) {
        tzData = location.lookupTimeZone(tzData.start - 1);
      } else if (utc >= tzData.end) {
        tzData = location.lookupTimeZone(tzData.end);
      }
      unix -= tzData.timeZone.offset;
    }
    return new DateTime.fromMillisecondsSinceEpoch(unix, isUtc: true);
  }

  /// Native [DateTime] used as a Calendar object.
  ///
  /// Represents the same date and time as this [TZDateTime], but in the UTC
  /// time zone. For example, for a [TZDateTime] representing
  /// 2000-03-17T12:00:00-0700, this will store the [DateTime] representing
  /// 2000-03-17T12:00:00Z.
  final DateTime _localDateTime;

  /// Native [DateTime] used as canonical, utc representation.
  ///
  /// Represents the same moment as this [TZDateTime].
  final DateTime _native;

  /// The number of milliseconds since
  /// the "Unix epoch" 1970-01-01T00:00:00Z (UTC).
  ///
  /// This value is independent of the time zone.
  ///
  /// This value is at most
  /// 8,640,000,000,000,000ms (100,000,000 days) from the Unix epoch.
  /// In other words: [:millisecondsSinceEpoch.abs() <= 8640000000000000:].
  int get millisecondsSinceEpoch => _native.millisecondsSinceEpoch;

  /// The number of microseconds since the "Unix epoch"
  /// 1970-01-01T00:00:00Z (UTC).
  ///
  /// This value is independent of the time zone.
  ///
  /// This value is at most 8,640,000,000,000,000,000us (100,000,000 days) from
  /// the Unix epoch. In other words:
  /// microsecondsSinceEpoch.abs() <= 8640000000000000000.
  ///
  /// Note that this value does not fit into 53 bits (the size of a IEEE
  /// double).  A JavaScript number is not able to hold this value.
  int get microsecondsSinceEpoch => _native.microsecondsSinceEpoch;

  /// [Location]
  final Location location;

  /// [TimeZone]
  final TimeZone timeZone;

  /// True if this [TZDateTime] is set to UTC time.
  ///
  /// ```dart
  /// final dDay = new TZDateTime.utc(1944, 6, 6);
  /// assert(dDay.isUtc);
  /// ```
  ///
  bool get isUtc => _isUtc(location);

  static bool _isUtc(Location l) => identical(l, UTC);

  /// True if this [TZDateTime] is set to Local time.
  ///
  /// ```dart
  /// final dDay = new TZDateTime.local(1944, 6, 6);
  /// assert(dDay.isLocal);
  /// ```
  ///
  bool get isLocal => identical(location, local);

  /// Constructs a [TZDateTime] instance specified at [location] time zone.
  ///
  /// For example,
  /// to create a new TZDateTime object representing April 29, 2014, 6:04am
  /// in America/Detroit:
  ///
  /// ```dart
  /// final detroit = getLocation('America/Detroit');
  ///
  /// final annularEclipse = new TZDateTime(location,
  ///     2014, DateTime.APRIL, 29, 6, 4);
  /// ```
  TZDateTime(Location location, int year,
      [int month = 1,
      int day = 1,
      int hour = 0,
      int minute = 0,
      int second = 0,
      int millisecond = 0,
      int microsecond = 0])
      : this.from(
            _utcFromLocalDateTime(
            st
            new DateTime.utc(year, month, day, hour, minute, second,
                    millisecond, microsecond),
                location),
            location);

  /// Constructs a [TZDateTime] instance specified in the UTC time zone.
  ///
  /// ```dart
  /// final dDay = new TZDateTime.utc(1944, TZDateTime.JUNE, 6);
  /// ```
  TZDateTime.utc(int year,
      [int month = 1,
      int day = 1,
      int hour = 0,
      int minute = 0,
      int second = 0,
      int millisecond = 0,
      int microsecond = 0])
      : this(UTC, year, month, day, hour, minute, second, millisecond,
            microsecond);

  /// Constructs a [TZDateTime] instance specified in the local time zone.
  ///
  /// ```dart
  /// final dDay = new TZDateTime.utc(1944, TZDateTime.JUNE, 6);
  /// ```
  TZDateTime.local(int year,
      [int month = 1,
      int day = 1,
      int hour = 0,
      int minute = 0,
      int second = 0,
      int millisecond = 0,
      int microsecond = 0])
      : this(local, year, month, day, hour, minute, second, millisecond,
            microsecond);

  /// Constructs a [TZDateTime] instance with current date and time in the
  /// [location] time zone.
  ///
  /// ```dart
  /// final detroit = getLocation('America/Detroit');
  ///
  /// final thisInstant = new TZDateTime.now(detroit);
  /// ```
  TZDateTime.now(Location location) : this.from(new DateTime.now(), location);

  /// Constructs a new [TZDateTime] instance with the given
  /// [millisecondsSinceEpoch].
  ///
  /// The constructed [TZDateTime] represents
  /// 1970-01-01T00:00:00Z + [millisecondsSinceEpoch] ms in the given
  /// time zone [location].
  TZDateTime.fromMillisecondsSinceEpoch(
      Location location, int millisecondsSinceEpoch)
      : this.from(
            new DateTime.fromMillisecondsSinceEpoch(millisecondsSinceEpoch,
                isUtc: true),
            location);

  TZDateTime.fromMicrosecondsSinceEpoch(
      Location location, int microsecondsSinceEpoch)
      : this.from(
            new DateTime.fromMicrosecondsSinceEpoch(microsecondsSinceEpoch,
                isUtc: true),
            location);

  /// Constructs a new [TZDateTime] instance from the given [DateTime]
  /// in the specified [location].
  ///
  /// ```dart
  /// final laTime = new TZDateTime(la, 2010, 1, 1);
  /// final detroitTime = new TZDateTime.from(detroit, laTime);
  /// ```
  TZDateTime.from(DateTime other, Location location)
      : this._(
            _toNative(other),
            location,
            _isUtc(location)
                ? TimeZone.UTC
                : location.timeZone(other.millisecondsSinceEpoch));

  TZDateTime._(DateTime native, Location location, TimeZone timeZone)
      : _native = native,
        _localDateTime =
            _isUtc(location) ? native : native.add(_timeZoneOffset(timeZone)),
        location = location,
        timeZone = timeZone;

  /// Constructs a new [TZDateTime] instance based on [formattedString].
  ///
  /// Throws a [FormatException] if the input cannot be parsed.
  ///
  /// The function parses a subset of ISO 8601
  /// which includes the subset accepted by RFC 3339.
  ///
  /// The result is always in the time zone of the provided location.
  ///
  /// Examples of accepted strings:
  ///
  /// * `"2012-02-27 13:27:00"`
  /// * `"2012-02-27 13:27:00.123456z"`
  /// * `"20120227 13:27:00"`
  /// * `"20120227T132700"`
  /// * `"20120227"`
  /// * `"+20120227"`
  /// * `"2012-02-27T14Z"`
  /// * `"2012-02-27T14+00:00"`
  /// * `"-123450101 00:00:00 Z"`: in the year -12345.
  /// * `"2002-02-27T14:00:00-0500"`: Same as `"2002-02-27T19:00:00Z"`
  static TZDateTime parse(Location location, String formattedString) {
    return new TZDateTime.from(DateTime.parse(formattedString), location);
  }

  /// Returns this DateTime value in the UTC time zone.
  ///
  /// Returns [this] if it is already in UTC.
  TZDateTime toUtc() => isUtc ? this : new TZDateTime.from(_native, UTC);

  /// Returns this DateTime value in the local time zone.
  ///
  /// Returns [this] if it is already in the local time zone.
  TZDateTime toLocal() => isLocal ? this : new TZDateTime.from(_native, local);

  static String _fourDigits(int n) {
    int absN = n.abs();
    String sign = n < 0 ? "-" : "";
    if (absN >= 1000) return "$n";
    if (absN >= 100) return "${sign}0$absN";
    if (absN >= 10) return "${sign}00$absN";
    return "${sign}000$absN";
  }

  static String _threeDigits(int n) {
    if (n >= 100) return "${n}";
    if (n >= 10) return "0${n}";
    return "00${n}";
  }

  static String _twoDigits(int n) {
    if (n >= 10) return "${n}";
    return "0${n}";
  }

  /// Returns a human-readable string for this instance.
  ///
  /// The returned string is constructed for the time zone of this instance.
  /// The `toString()` method provides a simply formatted string.
  /// It does not support internationalized strings.
  /// Use the [intl](http://pub.dartlang.org/packages/intl) package
  /// at the pub shared packages repo.
  String toString() => toIso8601String();

  /// Returns an ISO-8601 full-precision extended format representation.
  /// The format is "YYYY-MM-DDTHH:mm:ss.mmm[uuu]Z" for UTC time, and
  /// "YYYY-MM-DDTHH:mm:ss.mmm[uuu]±hhmm" for non-UTC time.
  String toIso8601String() {
    var offset = timeZone.offset;

    String y = _fourDigits(year);
    String m = _twoDigits(month);
    String d = _twoDigits(day);
    String h = _twoDigits(hour);
    String min = _twoDigits(minute);
    String sec = _twoDigits(second);
    String ms = _threeDigits(millisecond);
    String us = microsecond == 0 ? "" : _threeDigits(microsecond);

    if (isUtc || offset == 0) {
      return "$y-$m-$d $h:$min:$sec.$ms${us}Z";
    } else {
      String offSign = offset.sign > 0 ? '+' : '-';
      offset = offset.abs() ~/ 1000;
      String offH = _twoDigits(offset ~/ 3600);
      String offM = _twoDigits((offset % 3600) ~/ 60);

      return "$y-$m-$d $h:$min:$sec.$ms$us$offSign$offH$offM";
    }
  }

  /// Returns a new [TZDateTime] instance with [duration] added to [this].
  TZDateTime add(Duration duration) =>
      new TZDateTime.from(_native.add(duration), location);

  /// Returns a new [TZDateTime] instance with [duration] subtracted from
  /// [this].
  TZDateTime subtract(Duration duration) =>
      new TZDateTime.from(_native.subtract(duration), location);

  /// Returns a [Duration] with the difference between [this] and [other].
  Duration difference(DateTime other) => _native.difference(_toNative(other));

  /// Returns true if [other] is a [TZDateTime] at the same moment and in the
  /// same [Location].
  ///
  /// ```dart
  /// final detroit   = getLocation('America/Detroit');
  /// final dDayUtc   = new TZDateTime.utc(1944, DateTime.JUNE, 6);
  /// final dDayLocal = new TZDateTime(detroit, 1944, DateTime.JUNE, 6);
  ///
  /// assert(dDayUtc.isAtSameMomentAs(dDayLocal) == false);
  /// ````
  ///
  /// See [isAtSameMomentAs] for a comparison that adjusts for time zone.
  bool operator ==(other) {
    return identical(this, other) ||
        other is TZDateTime &&
            _native.isAtSameMomentAs(other._native) &&
            location == other.location;
  }

  /// Returns true if [this] occurs before [other].
  ///
  /// The comparison is independent of whether the time is in UTC or in other
  /// time zone.
  ///
  /// ```dart
  /// final berlinWallFell = new TZDateTime(UTC, 1989, 11, 9);
  /// final moonLanding    = new TZDateTime(UTC, 1969, 7, 20);
  ///
  /// assert(berlinWallFell.isBefore(moonLanding) == false);
  /// ```
  bool isBefore(DateTime other) =>
      _native.isBefore(other is TZDateTime ? other._native : other);

  /// Returns true if [this] occurs after [other].
  ///
  /// The comparison is independent of whether the time is in UTC or in other
  /// time zone.
  ///
  /// ```dart
  /// final berlinWallFell = new TZDateTime(UTC, 1989, 11, 9);
  /// final moonLanding    = new TZDateTime(UTC, 1969, 7, 20);
  ///
  /// assert(berlinWallFell.isAfter(moonLanding) == true);
  /// ```
  bool isAfter(DateTime other) =>
      _native.isAfter(other is TZDateTime ? other._native : other);

  /// Returns true if [this] occurs at the same moment as [other].
  ///
  /// The comparison is independent of whether the time is in UTC or in other
  /// time zone.
  ///
  /// ```dart
  /// final berlinWallFell = new TZDateTime(UTC, 1989, 11, 9);
  /// final moonLanding    = new TZDateTime(UTC, 1969, 7, 20);
  ///
  /// assert(berlinWallFell.isAtSameMomentAs(moonLanding) == false);
  /// ```
  bool isAtSameMomentAs(DateTime other) =>
      _native.isAtSameMomentAs(_toNative(other));

  /// Compares this [TZDateTime] object to [other],
  /// returning zero if the values occur at the same moment.
  ///
  /// This function returns a negative integer
  /// if this [TZDateTime] is smaller (earlier) than [other],
  /// or a positive integer if it is greater (later).
  int compareTo(DateTime other) => _native.compareTo(_toNative(other));

  int get hashCode => _native.hashCode;

  /// The abbreviated time zone name&mdash;for example,
  /// [:"CET":] or [:"CEST":].
  String get timeZoneName => timeZone.abbr;

  /// The time zone offset, which is the difference between time at [location]
  /// and UTC.
  ///
  /// The offset is positive for time zones east of UTC.
  ///
  /// Note, that JavaScript, Python and C return the difference between UTC and
  /// local time. Java, C# and Ruby return the difference between local time and
  /// UTC.
  Duration get timeZoneOffset => _timeZoneOffset(timeZone);

  static Duration _timeZoneOffset(TimeZone timeZone) =>
      new Duration(milliseconds: timeZone.offset);

  /// The year.
  int get year => _localDateTime.year;

  /// The month [1..12].
  int get month => _localDateTime.month;

  /// The day of the month [1..31].
  int get day => _localDateTime.day;

  /// The hour of the day, expressed as in a 24-hour clock [0..23].
  int get hour => _localDateTime.hour;

  /// The minute [0...59].
  int get minute => _localDateTime.minute;

  /// The second [0...59].
  int get second => _localDateTime.second;

  /// The millisecond [0...999].
  int get millisecond => _localDateTime.millisecond;

  /// The microsecond [0...999].
  int get microsecond => _localDateTime.microsecond;

  /// The day of the week.
  ///
  /// In accordance with ISO 8601
  /// a week starts with Monday, which has the value 1.
  int get weekday => _localDateTime.weekday;
}
