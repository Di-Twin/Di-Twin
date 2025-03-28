import Cta from "~/components/Section/Common/Cta";
import Footer from "~/components/Section/Common/Footer";
import BrandSection from "~/components/Section/Home-1/Brand/Brand";
import ContentSectionOne from "~/components/Section/Home-1/Content/ContentOne";
import ContentSectionTwo from "~/components/Section/Home-1/Content/ContentTwo";
import Faq from "~/components/Section/Home-1/Faq/Faq";
import FeatureSection from "~/components/Section/Home-2/Feature/Feature";
import HeroSection from "~/components/Section/Home-1/Hero/Hero";
import NewsSection from "~/components/Section/Home-1/News/News";
import { ContentOne, ContentTwo } from "~/components/Section/Home-2/Content";
import { HomeHeaderTwo } from "~/components/Section/Common/Header";

export default function Home() {
  return (
    <>
      <HomeHeaderTwo />
      <HeroSection />
      <BrandSection />
      <ContentSectionOne />
      <ContentSectionTwo />
      <FeatureSection />
      <Faq />
      <ContentOne/>
      <ContentTwo/>
      <NewsSection />
      <Cta />
      <Footer />
    </>
  );
}
