/* eslint-disable react/no-unescaped-entities */

import Link from "next/link";
import {
  FaFacebookF,
  FaGithub,
  FaInstagram,
  FaLinkedin,
  FaTwitter,
} from "react-icons/fa";

const Footer = () => {
  const currentYear = new Date().getFullYear(); // Get the current year dynamically

  return (
    <footer className="zubuz-footer-section main-footer white-bg">
      <div className="container">
        <div className="zubuz-footer-top">
          <div className="row">
            <div className="col-xl-4 col-lg-12">
              <div className="zubuz-footer-textarea">
                <Link href="">
                  <img src="/images/logo/logo-dark.svg" alt="DI-Twin Logo" />
                </Link>
                <p>
                  <strong>DI-Twin</strong> is an AI-powered digital twin for
                  preventive healthcare. We help users predict, prevent, and
                  manage chronic diseases with advanced analytics, personalized
                  recommendations, and wearable device integration.
                </p>
                <div className="zubuz-subscribe-one">
                  <form>
                    <input type="email" placeholder="Email Address" />
                    <button
                      className="zubuz-default-btn zubuz-subscription-btn one"
                      id="zubuz-subscription-btn"
                      type="submit"
                    >
                      <span>Subscribe</span>
                    </button>
                  </form>
                </div>
              </div>
            </div>
            <div className="col-xl-3 col-md-4">
              <div className="zubuz-footer-menu extar-margin">
                <div className="zubuz-footer-title">
                  <p>Navigation</p>
                </div>
                <ul>
                  <li>
                    <Link href="">Home</Link>
                  </li>
                  <li>
                    <Link href="">Features</Link>
                  </li>
                  <li>
                    <Link href="">Why us?</Link>
                  </li>
                  <li>
                    <Link href="">News</Link>
                  </li>
                </ul>
              </div>
            </div>
            {/* <div className="col-xl-2 col-md-4">
              <div className="zubuz-footer-menu">
                <div className="zubuz-footer-title">
                  <p>Utility Pages</p>
                </div>
                <ul>
                  <li>
                    <Link href="">Instructions</Link>
                  </li>
                  <li>
                    <Link href="">Style Guide</Link>
                  </li>
                  <li>
                    <Link href="">Licenses</Link>
                  </li>
                  <li>
                    <Link href="">404 Not Found</Link>
                  </li>
                  <li>
                    <Link href="">Password Protected</Link>
                  </li>
                </ul>
              </div>
            </div> */}
            <div className="col-xl-3 col-md-4">
              <div className="zubuz-footer-menu extar-margin">
                <div className="zubuz-footer-title">
                  <p>Resources</p>
                </div>
                <ul>
                  <li>
                    <Link href="">Support</Link>
                  </li>
                  <li>
                    <Link href="">Privacy Policy</Link>
                  </li>
                  <li>
                    <Link href="">Terms & Conditions</Link>
                  </li>
                  <li>
                    <Link href="">Health Insights</Link>
                  </li>
                  <li>
                    <Link href="">Video Guide</Link>
                  </li>
                </ul>
              </div>
            </div>
          </div>
        </div>
        <div className="zubuz-footer-bottom">
          <div className="zubuz-social-icon order-md-2">
            <ul>
              <li>
                <a href="#" target="_blank">
                  <FaTwitter />
                </a>
              </li>
              <li>
                <a href="#" target="_blank">
                  <FaFacebookF />
                </a>
              </li>
              <li>
                <a
                  href="https://www.instagram.com/dtwin_social?igsh=MXJ1OTdlN25veDAxdA%3D%3D&utm_source=qr"
                  target="_blank"
                >
                  <FaInstagram />
                </a>
              </li>
              <li>
                <a href="#" target="_blank">
                  <FaLinkedin />
                </a>
              </li>
            </ul>
          </div>
          <div className="zubuz-copywright">
            <p>
              © {currentYear}, All Rights Reserved by{" "}
              <strong>EvenBetter</strong>
            </p>
          </div>
        </div>
      </div>
    </footer>
  );
};

export default Footer;
