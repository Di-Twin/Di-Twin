import FAQSection from "~/components/Section/Common/FAQ/FAQSection";
import Footer from "~/components/Section/Common/Footer";
import PageHeader from "~/components/Section/Common/PageHeader";
import CallUs from "~/components/Section/ContactUs/CallUs";
import ContactSection from "~/components/Section/ContactUs/Contact/ContactSection";
import { HomeHeaderTwo } from "~/components/Section/Common/Header";


const ContactUsPage = () => {
  return (
    <>
      <HomeHeaderTwo />
      <ContactSection />
      <CallUs />
      <Footer />
    </>
  );
};

export default ContactUsPage;
