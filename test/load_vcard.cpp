/*
 * Copyright 2011 Intel Corporation.
 *
 * This program is licensed under the terms and conditions of the
 * Apache License, version 2.0.  The full text of the Apache License is at 	
 * http://www.apache.org/licenses/LICENSE-2.0
 */

#include <QDebug>
#include <QContact>
#include <QContactManagerEngine>
#include <QContactSaveRequest>
#include <QVersitReader>
#include <QFile>
#include <QBuffer>
#include <QVersitContactImporter>
#include <QtTest/QtTest>

QTM_USE_NAMESPACE

class Load_Vcard: public QObject
{
    Q_OBJECT

private slots:
    void addNewContacts_data();
    void addNewContacts();
};

void Load_Vcard::addNewContacts_data()
{
     QTest::addColumn<QString>("vcard");
     QTest::addColumn<QString>("result");

     QTest::newRow("CHS") << "vcardCHS.vcf" << "0";
     QTest::newRow("CHT") << "vcardCHT.vcf" << "0";
     QTest::newRow("CSY") << "vcardCSY.vcf" << "0";
     QTest::newRow("DAN") << "vcardDAN.vcf" << "0";
     QTest::newRow("DEU") << "vcardDEU.vcf" << "0";
     QTest::newRow("ELL") << "vcardELL.vcf" << "0";
     QTest::newRow("ESP") << "vcardESP.vcf" << "0";
     QTest::newRow("FIN") << "vcardFIN.vcf" << "0";
     QTest::newRow("FRA") << "vcardFRA.vcf" << "0";
     QTest::newRow("HUN") << "vcardHUN.vcf" << "0";
     QTest::newRow("ITA") << "vcardITA.vcf" << "0";
     QTest::newRow("JPN") << "vcardJPN.vcf" << "0";
     QTest::newRow("KOR") << "vcardKOR.vcf" << "0";
     QTest::newRow("NLD") << "vcardNLD.vcf" << "0";
     QTest::newRow("NOR") << "vcardNOR.vcf" << "0";
     QTest::newRow("PLK") << "vcardPLK.vcf" << "0";
     QTest::newRow("PTB") << "vcardPTB.vcf" << "0";
     QTest::newRow("PTG") << "vcardPTG.vcf" << "0";
     QTest::newRow("RUS") << "vcardRUS.vcf" << "0";
     QTest::newRow("SVE") << "vcardSVE.vcf" << "0";
     QTest::newRow("TRK") << "vcardTRK.vcf" << "0";
     QTest::newRow("example") << "example.vcf" << "0";
}

/*
void Load_Vcard::contactsSaved()
{
    QContactSaveRequest *request = qobject_cast<QContactSaveRequest*>(QObject::sender());

    if (request->error() != QContactManager::NoError)
        return;

    qDebug() << "[TEST] Saving " << request->contacts().size() << " contacts";
}
*/

void Load_Vcard::addNewContacts()
{
    QFETCH(QString, vcard);
    QFETCH(QString, result);

    QList<QContact> contacts;
    QString res = QString("1"); 

    QContactManager *cm = new QContactManager();
    QContactSaveRequest *m_contactSaveRequest = new QContactSaveRequest();
    m_contactSaveRequest->setManager(cm);
    //connect(&m_contactSaveRequest, SIGNAL(resultsAvailable()), this,
    //        SLOT(contactsSaved()));

    QFile file(vcard);
    if (file.exists()) {
        QByteArray cardArr;
        if (file.open(QFile::ReadOnly)) {
            while (!file.atEnd()) {
                cardArr.append(file.readLine());
            }
        }

        QBuffer input;
        input.open(QBuffer::ReadWrite);
        input.write(cardArr);
        input.seek(0);

        QVersitReader reader(cardArr);
        reader.startReading();
        reader.waitForFinished();
        QList<QVersitDocument> inputDocuments = reader.results();

        QVersitContactImporter importer;
        if (importer.importDocuments(inputDocuments)) {
            contacts = importer.contacts();
            m_contactSaveRequest->setContacts(contacts);
            m_contactSaveRequest->start();
            m_contactSaveRequest->waitForFinished();
            res = QString("0"); 
        }

        input.close();
        file.close();
    }
    delete m_contactSaveRequest;
    delete cm;

    QCOMPARE(res, result);
}

QTEST_MAIN(Load_Vcard)
#include "load_vcard.moc"
