#define BOOST_TEST_DYN_LINK
#define BOOST_TEST_MODULE TestBoostLink
#include <boost/test/unit_test.hpp>

BOOST_AUTO_TEST_CASE(simple_test) {
    BOOST_CHECK(true);
}
