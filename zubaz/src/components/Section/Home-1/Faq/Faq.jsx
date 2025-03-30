"use client";
import Link from "next/link";
import Accordion from "react-bootstrap/Accordion";

const Faq = () => {
  return (
    <div className="scetion zubuz-section-padding2 white-bg">
      <div className="container">
        <div className="row">
          <div className="col-lg-7 order-lg-2">
            <div className="zubuz-default-content">
              <h2>Understand Your Health with AI-Powered Scores</h2>
              <p>
                DTwin provides <strong>personalized health insights</strong>{" "}
                through a<strong> comprehensive scoring system</strong>. Our AI
                analyzes your
                <strong>
                  {" "}
                  daily habits, sleep, nutrition, and activity
                </strong>{" "}
                to generate real-time <strong>health scores</strong> that help
                you make informed decisions.
              </p>
              <p>
                Each score—<strong>Health, Sleep, Activity, and Food</strong>—is
                designed to give you a{" "}
                <strong>clear picture of your overall well-being</strong>. Learn
                how they work and take control of your health today.
              </p>
              <div className="zubuz-extara-mt">
                <Link className="zubuz-default-btn" href="contact-us">
                  <span>Start Your Health Journey</span>
                </Link>
              </div>
            </div>
          </div>
          <div className="col-lg-5">
            <div className="zubuz-accordion-wrap">
              <Accordion defaultActiveKey="0" flush>
                <Accordion.Item eventKey="0">
                  <Accordion.Header>Health Score</Accordion.Header>
                  <Accordion.Body>
                    <strong>Track your overall well-being</strong>. Get a
                    <strong> simplified health overview</strong> that helps you
                    understand where you stand and what steps to take for a
                    <strong> healthier lifestyle</strong>.
                  </Accordion.Body>
                </Accordion.Item>
                <Accordion.Item eventKey="1">
                  <Accordion.Header>Sleep Score</Accordion.Header>
                  <Accordion.Body>
                    <strong>Improve your sleep quality</strong>. Get insights
                    into
                    <strong> how well you rest</strong> and personalized tips to
                    <strong> wake up feeling refreshed</strong> and full of
                    energy.
                  </Accordion.Body>
                </Accordion.Item>
                <Accordion.Item eventKey="2">
                  <Accordion.Header>Activity Score</Accordion.Header>
                  <Accordion.Body>
                    <strong>Stay active effortlessly</strong>. See how your
                    daily
                    <strong> movement and exercise</strong> contribute to your
                    health and receive <strong>customized fitness goals</strong>{" "}
                    to keep you motivated.
                  </Accordion.Body>
                </Accordion.Item>
                <Accordion.Item eventKey="3">
                  <Accordion.Header>Food Score</Accordion.Header>
                  <Accordion.Body>
                    <strong>Eat smarter, live better</strong>. Get AI-powered
                    food insights that help you{" "}
                    <strong>balance your meals</strong>, make healthier choices,
                    and <strong>boost your nutrition</strong>.
                  </Accordion.Body>
                </Accordion.Item>
              </Accordion>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};

export default Faq;
