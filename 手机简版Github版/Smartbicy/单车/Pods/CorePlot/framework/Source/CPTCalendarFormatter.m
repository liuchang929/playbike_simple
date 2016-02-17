#import "CPTCalendarFormatter.h"

#import "CPTExceptions.h"

/** @brief A number formatter that converts calendar intervals to dates.
 *
 *  Useful for formatting labels on an axis. The numerical
 *  scale of the plot space will be used to increment the specified calendar unit.
 *  For example, with a @link CPTAxis::majorIntervalLength majorIntervalLength @endlink of one (@num{1}) and a
 *  @ref referenceCalendarUnit of
 *  @ref NSMonthCalendarUnit, successive months will be displayed on the axis.
 *  Axis labels can be directly generated by setting a CPTCalendarFormatter as the @link CPTAxis::labelFormatter labelFormatter @endlink
 *  and/or @link CPTAxis::minorTickLabelFormatter minorTickLabelFormatter @endlink.
 **/
@implementation CPTCalendarFormatter

/** @property NSDateFormatter *dateFormatter
 *  @brief The date formatter used to generate strings from date calculations.
 **/
@synthesize dateFormatter;

/** @property NSDate *referenceDate
 *  @brief Date from which time intervals are computed.
 *  If @nil, the standard reference date (1 January 2001, GMT) is used.
 **/
@synthesize referenceDate;

/** @property NSCalendar *referenceCalendar
 *  @brief Calendar which is used for date calculations.
 *  If @nil, the current calendar is used.
 **/
@synthesize referenceCalendar;

/** @property NSCalendarUnit referenceCalendarUnit
 *  @brief Calendar unit which is incremented in the date calculation.
 *  If zero (@num{0}), the date is incremented.
 **/
@synthesize referenceCalendarUnit;

#pragma mark -
#pragma mark Init/Dealloc

/// @name Initialization
/// @{

/** @brief Initializes a newly allocated CPTCalendarFormatter object with a default date formatter.
 *  The default formatter uses @ref NSDateFormatterMediumStyle for dates and times.
 *  @return The initialized object.
 **/
-(id)init
{
    NSDateFormatter *newDateFormatter = [[NSDateFormatter alloc] init];

    newDateFormatter.dateStyle = NSDateFormatterMediumStyle;
    newDateFormatter.timeStyle = NSDateFormatterMediumStyle;

    self = [self initWithDateFormatter:newDateFormatter];
    [newDateFormatter release];

    return self;
}

/// @}

/** @brief Initializes new instance with the date formatter passed.
 *  @param aDateFormatter The date formatter.
 *  @return The new instance.
 **/
-(id)initWithDateFormatter:(NSDateFormatter *)aDateFormatter
{
    if ( (self = [super init]) ) {
        dateFormatter         = [aDateFormatter retain];
        referenceDate         = nil;
        referenceCalendar     = nil;
        referenceCalendarUnit = NSEraCalendarUnit;
    }
    return self;
}

/// @cond

-(void)dealloc
{
    [referenceCalendar release];
    [referenceDate release];
    [dateFormatter release];
    [super dealloc];
}

/// @endcond

#pragma mark -
#pragma mark NSCoding Methods

/// @cond

-(void)encodeWithCoder:(NSCoder *)coder
{
    [super encodeWithCoder:coder];

    [coder encodeObject:self.dateFormatter forKey:@"CPTCalendarFormatter.dateFormatter"];
    [coder encodeObject:self.referenceDate forKey:@"CPTCalendarFormatter.referenceDate"];
    [coder encodeObject:self.referenceCalendar forKey:@"CPTCalendarFormatter.referenceCalendar"];
    [coder encodeInteger:(NSInteger)self.referenceCalendarUnit forKey:@"CPTCalendarFormatter.referenceCalendarUnit"];
}

-(id)initWithCoder:(NSCoder *)coder
{
    if ( (self = [super initWithCoder:coder]) ) {
        dateFormatter         = [[coder decodeObjectForKey:@"CPTCalendarFormatter.dateFormatter"] retain];
        referenceDate         = [[coder decodeObjectForKey:@"CPTCalendarFormatter.referenceDate"] copy];
        referenceCalendar     = [[coder decodeObjectForKey:@"CPTCalendarFormatter.referenceCalendar"] copy];
        referenceCalendarUnit = (NSCalendarUnit)[coder decodeIntegerForKey : @"CPTCalendarFormatter.referenceCalendarUnit"];
    }
    return self;
}

/// @endcond

#pragma mark -
#pragma mark NSCopying Methods

/// @cond

-(id)copyWithZone:(NSZone *)zone
{
    CPTCalendarFormatter *newFormatter = [[CPTCalendarFormatter allocWithZone:zone] init];

    if ( newFormatter ) {
        newFormatter->dateFormatter         = [self->dateFormatter copyWithZone:zone];
        newFormatter->referenceDate         = [self->referenceDate copyWithZone:zone];
        newFormatter->referenceCalendar     = [self->referenceCalendar copyWithZone:zone];
        newFormatter->referenceCalendarUnit = self->referenceCalendarUnit;
    }
    return newFormatter;
}

/// @endcond

#pragma mark -
#pragma mark Formatting

/// @name Formatting
/// @{

/**
 *  @brief Converts decimal number for the time into a date string.
 *  Uses the date formatter to do the conversion. Conversions are relative to the
 *  reference date, unless it is @nil, in which case the standard reference date
 *  of 1 January 2001, GMT is used.
 *  @param coordinateValue The time value.
 *  @return The date string.
 **/
-(NSString *)stringForObjectValue:(id)coordinateValue
{
    NSInteger componentIncrement = 0;

    if ( [coordinateValue respondsToSelector:@selector(integerValue)] ) {
        componentIncrement = [coordinateValue integerValue];
    }

    NSDateComponents *dateComponents = [[[NSDateComponents alloc] init] autorelease];

    switch ( self.referenceCalendarUnit ) {
        case NSEraCalendarUnit:
            dateComponents.era = componentIncrement;
            break;

        case NSYearCalendarUnit:
            dateComponents.year = componentIncrement;
            break;

        case NSMonthCalendarUnit:
            dateComponents.month = componentIncrement;
            break;

        case NSWeekCalendarUnit:
            //dateComponents.week = componentIncrement;
            break;

        case NSDayCalendarUnit:
            dateComponents.day = componentIncrement;
            break;

        case NSHourCalendarUnit:
            dateComponents.hour = componentIncrement;
            break;

        case NSMinuteCalendarUnit:
            dateComponents.minute = componentIncrement;
            break;

        case NSSecondCalendarUnit:
            dateComponents.second = componentIncrement;
            break;

        case NSWeekdayCalendarUnit:
            dateComponents.weekday = componentIncrement;
            break;

        case NSWeekdayOrdinalCalendarUnit:
            dateComponents.weekdayOrdinal = componentIncrement;
            break;

#if MAC_OS_X_VERSION_10_5 < MAC_OS_X_VERSION_MAX_ALLOWED || __IPHONE_3_0 < __IPHONE_OS_VERSION_MAX_ALLOWED
        case NSQuarterCalendarUnit:
            if ( [dateComponents respondsToSelector:@selector(setQuarter:)] ) {
                dateComponents.quarter = componentIncrement;
            }
            else {
                [NSException raise:CPTException format:@"Unsupported calendar unit: NSQuarterCalendarUnit"];
            }
            break;
#endif
#if MAC_OS_X_VERSION_10_6 < MAC_OS_X_VERSION_MAX_ALLOWED || __IPHONE_4_0 < __IPHONE_OS_VERSION_MAX_ALLOWED
        case NSWeekOfMonthCalendarUnit:
            if ( [dateComponents respondsToSelector:@selector(setWeekOfMonth:)] ) {
                dateComponents.weekOfMonth = componentIncrement;
            }
            else {
                [NSException raise:CPTException format:@"Unsupported calendar unit: NSWeekOfMonthCalendarUnit"];
            }
            break;

        case NSWeekOfYearCalendarUnit:
            if ( [dateComponents respondsToSelector:@selector(setWeekOfYear:)] ) {
                dateComponents.weekOfYear = componentIncrement;
            }
            else {
                [NSException raise:CPTException format:@"Unsupported calendar unit: NSWeekOfYearCalendarUnit"];
            }
            break;

        case NSYearForWeekOfYearCalendarUnit:
            if ( [dateComponents respondsToSelector:@selector(setYearForWeekOfYear:)] ) {
                dateComponents.yearForWeekOfYear = componentIncrement;
            }
            else {
                [NSException raise:CPTException format:@"Unsupported calendar unit: NSYearForWeekOfYearCalendarUnit"];
            }
            break;
#endif
#if MAC_OS_X_VERSION_10_7 < MAC_OS_X_VERSION_MAX_ALLOWED || __IPHONE_4_0 < __IPHONE_OS_VERSION_MAX_ALLOWED
        case NSCalendarCalendarUnit:
            [NSException raise:CPTException format:@"Unsupported calendar unit: NSCalendarCalendarUnit"];
            break;

        case NSTimeZoneCalendarUnit:
            [NSException raise:CPTException format:@"Unsupported calendar unit: NSTimeZoneCalendarUnit"];
            break;
#endif
        default:
            break;
    }

    NSDate *startDate = [NSDate dateWithTimeIntervalSinceReferenceDate:0];
    if ( self.referenceDate ) {
        startDate = self.referenceDate;
    }

    NSCalendar *calendar = [NSCalendar currentCalendar];
    if ( self.referenceCalendar ) {
        calendar = self.referenceCalendar;
    }

    NSDate *computedDate = [calendar dateByAddingComponents:dateComponents toDate:startDate options:0];

    NSString *string = [self.dateFormatter stringFromDate:computedDate];
    return string;
}

/// @}

@end
