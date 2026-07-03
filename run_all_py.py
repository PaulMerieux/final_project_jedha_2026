import main
import script_connexion_RDS

if __name__ == "__main__":
    print("DÉMARRAGE DU PIPELINE COMPLET (END-TO-END)")

    main.run()
    script_connexion_RDS.run()

    print("S3 est propre et RDS est rempli !")